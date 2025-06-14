import { describe, it, expect, beforeEach, vi } from 'vitest';
import { TradeShare } from '../src/durable/trade';
import { BackeEndEnv } from '../src/graphql/builder';

const qbMock = {
  ops: [] as any[],
  fetchAllResults: [] as any[],
  fetchOneResults: [] as any[],
  reset() {
    this.ops = [];
    this.fetchAllResults = [];
    this.fetchOneResults = [];
  },
};

vi.mock('workers-qb', () => {
  class D1QB {
    db: string;
    constructor(db: string) { this.db = db; }
    fetchAll(args: any) {
      qbMock.ops.push({ method: 'fetchAll', db: this.db, args });
      const res = qbMock.fetchAllResults.shift() ?? { success: true, results: [] };
      return { execute: async () => res };
    }
    fetchOne(args: any) {
      qbMock.ops.push({ method: 'fetchOne', db: this.db, args });
      const res = qbMock.fetchOneResults.shift() ?? { success: true, results: null };
      return { execute: async () => res };
    }
    insert(args: any) {
      qbMock.ops.push({ method: 'insert', db: this.db, args });
      return { op: 'insert', args };
    }
    update(args: any) {
      qbMock.ops.push({ method: 'update', db: this.db, args });
      return { op: 'update', args };
    }
    batchExecute(args: any) {
      qbMock.ops.push({ method: 'batchExecute', db: this.db, args });
      return { execute: async () => ({ success: true }) };
    }
  }
  return { D1QB };
});

function createTrade() {
  const env = { USER_DB: 'user' } as unknown as BackeEndEnv;
  const trade: any = Object.create(TradeShare.prototype);
  trade.env = env;
  trade.state = {
    blockConcurrencyWhile: async (fn: any) => fn(),
    getWebSockets: () => [],
  } as any;
  trade.sessions = new Map();
  trade.broadcast = vi.fn();
  trade.tax = 100;
  return trade as TradeShare;
}

beforeEach(() => {
  qbMock.reset();
  vi.useFakeTimers();
  vi.setSystemTime(0);
});

// Market buy order sorted by price
it('matches market buy with lowest ask first', async () => {
  const trade = createTrade();
  qbMock.fetchAllResults.push({
    results: [
      { id: 1, amount: 5, executed: 0, price: 12, createdAt: 0, orderType: 1, userId: 2 },
      { id: 2, amount: 10, executed: 0, price: 10, createdAt: 1, orderType: 1, userId: 3 },
    ],
  });

  const res = await trade.placeNewOrder(8, 0, 0, 1);
  expect(res.affected).toEqual([{ ownerId: 3, amount: 8, price: 10 }]);
  expect(res.totalPrice).toBe(80);
  expect(res.statements.changes).toHaveLength(2);
  const [insert, update] = res.statements.changes;
  expect(insert.op).toBe('insert');
  expect(insert.args.data).toMatchObject({ amount: 8, price: 0, orderType: 0, executed: 8, orderStatus: 2, userId: 1 });
  expect(update.args.where.params).toEqual([2]);
  expect(update.args.data).toMatchObject({ executed: 8, orderStatus: 1 });
});

// Limit buy order covers multiple sells
it('sorts limit buy orders with exact price first and handles partial fills', async () => {
  const trade = createTrade();
  qbMock.fetchAllResults.push({
    results: [
      { id: 2, amount: 3, executed: 0, price: 9, createdAt: 1, orderType: 1, userId: 4 },
      { id: 1, amount: 5, executed: 0, price: 10, createdAt: 0, orderType: 1, userId: 3 },
    ],
  });

  const res = await trade.placeNewOrder(7, 10, 0, 1);
  expect(res.affected).toEqual([
    { ownerId: 3, amount: 5, price: 10 },
    { ownerId: 4, amount: 2, price: 9 },
  ]);
  expect(res.totalPrice).toBe(5 * 10 + 2 * 9);
  expect(res.statements.changes).toHaveLength(3);
  const [update1, insert, update2] = res.statements.changes;
  expect(update1.args.where.params).toEqual([1]);
  expect(update1.args.data).toMatchObject({ executed: 5, orderStatus: 2 });
  expect(insert.args.data).toMatchObject({ amount: 7, price: 10, orderType: 0, executed: 2, orderStatus: 2, userId: 1 });
  expect(update2.args.where.params).toEqual([2]);
  expect(update2.args.data).toMatchObject({ executed: 2, orderStatus: 1 });
});

// Limit sell order with multiple bids
it('handles limit sell with bids sorted by price', async () => {
  const trade = createTrade();
  qbMock.fetchAllResults.push({
    results: [
      { id: 2, amount: 4, executed: 0, price: 12, createdAt: 0, orderType: 0, userId: 3 },
      { id: 1, amount: 4, executed: 0, price: 11, createdAt: 1, orderType: 0, userId: 2 },
    ],
  });

  const res = await trade.placeNewOrder(6, 11, 1, 1);
  expect(res.affected).toEqual([
    { ownerId: 2, amount: 4, price: 11 },
    { ownerId: 3, amount: 2, price: 12 },
  ]);
  expect(res.totalPrice).toBe(4 * 11 + 2 * 12);
  expect(res.statements.changes).toHaveLength(3);
  const [update1, insert, update2] = res.statements.changes;
  expect(update1.args.where.params).toEqual([1]);
  expect(update1.args.data).toMatchObject({ executed: 4, orderStatus: 2 });
  expect(insert.args.data).toMatchObject({ amount: 6, price: 11, orderType: 1, executed: 2, orderStatus: 2, userId: 1 });
  expect(update2.args.where.params).toEqual([2]);
  expect(update2.args.data).toMatchObject({ executed: 2, orderStatus: 1 });
});

// Leftover amount becomes open order
it('creates open order when unmatched amount remains', async () => {
  const trade = createTrade();
  qbMock.fetchAllResults.push({
    results: [
      { id: 1, amount: 2, executed: 0, price: 10, createdAt: 0, orderType: 1, userId: 2 },
    ],
  });

  const res = await trade.placeNewOrder(5, 10, 0, 1);
  expect(res.affected).toEqual([{ ownerId: 2, amount: 2, price: 10 }]);
  expect(res.totalPrice).toBe(20);
  expect(res.statements.changes).toHaveLength(2);
  const [update, insert] = res.statements.changes;
  expect(update.args.where.params).toEqual([1]);
  expect(update.args.data).toMatchObject({ executed: 2, orderStatus: 2 });
  expect(insert.args.data).toMatchObject({ amount: 5, price: 10, orderType: 0, executed: 2, orderStatus: 1, userId: 1 });
});

// Market sell selects highest bid first
it('matches market sell with highest bid first', async () => {
  const trade = createTrade();
  qbMock.fetchAllResults.push({
    results: [
      { id: 1, amount: 5, executed: 0, price: 10, createdAt: 1, orderType: 0, userId: 3 },
      { id: 2, amount: 5, executed: 0, price: 12, createdAt: 0, orderType: 0, userId: 2 },
    ],
  });

  const res = await trade.placeNewOrder(7, 0, 1, 1);
  expect(res.affected).toEqual([
    { ownerId: 2, amount: 5, price: 12 },
    { ownerId: 3, amount: 2, price: 10 },
  ]);
  expect(res.totalPrice).toBe(5 * 12 + 2 * 10);
  expect(res.statements.changes).toHaveLength(3);
  const [update1, insert, update2] = res.statements.changes;
  expect(update1.args.where.params).toEqual([2]);
  expect(update1.args.data).toMatchObject({ executed: 5, orderStatus: 2 });
  expect(insert.args.data).toMatchObject({ amount: 7, price: 0, orderType: 1, executed: 2, orderStatus: 2, userId: 1 });
  expect(update2.args.where.params).toEqual([1]);
  expect(update2.args.data).toMatchObject({ executed: 2, orderStatus: 1 });
});

// Market sell left open when not fully filled
it('creates open market sell order when insufficient bids', async () => {
  const trade = createTrade();
  qbMock.fetchAllResults.push({
    results: [
      { id: 1, amount: 2, executed: 0, price: 10, createdAt: 0, orderType: 0, userId: 2 },
    ],
  });

  const res = await trade.placeNewOrder(5, 0, 1, 1);
  expect(res.affected).toEqual([{ ownerId: 2, amount: 2, price: 10 }]);
  expect(res.totalPrice).toBe(20);
  expect(res.statements.changes).toHaveLength(2);
  const [update, insert] = res.statements.changes;
  expect(update.args.where.params).toEqual([1]);
  expect(update.args.data).toMatchObject({ executed: 2, orderStatus: 2 });
  expect(insert.args.data).toMatchObject({ amount: 5, price: 0, orderType: 1, executed: 2, orderStatus: 1, userId: 1 });
});

// Limit buy order with no available sells
it('creates open limit buy when no asks exist', async () => {
  const trade = createTrade();
  qbMock.fetchAllResults.push({ results: [] });

  const res = await trade.placeNewOrder(4, 11, 0, 1);
  expect(res.affected).toEqual([]);
  expect(res.totalPrice).toBe(0);
  expect(res.statements.changes).toHaveLength(1);
  const [insert] = res.statements.changes;
  expect(insert.args.data).toMatchObject({ amount: 4, price: 11, orderType: 0, executed: 0, orderStatus: 1, userId: 1 });
});

// Limit sell partially matched with remaining open amount
it('handles partial limit sell and leaves open order', async () => {
  const trade = createTrade();
  qbMock.fetchAllResults.push({
    results: [
      { id: 1, amount: 2, executed: 0, price: 9, createdAt: 0, orderType: 0, userId: 2 },
      { id: 2, amount: 2, executed: 0, price: 10, createdAt: 1, orderType: 0, userId: 3 },
    ],
  });

  const res = await trade.placeNewOrder(5, 9, 1, 1);
  expect(res.affected).toEqual([
    { ownerId: 2, amount: 2, price: 9 },
    { ownerId: 3, amount: 2, price: 10 },
  ]);
  expect(res.totalPrice).toBe(2 * 9 + 2 * 10);
  expect(res.statements.changes).toHaveLength(3);
  const [update1, update2, insert] = res.statements.changes;
  expect(update1.args.where.params).toEqual([1]);
  expect(update1.args.data).toMatchObject({ executed: 2, orderStatus: 2 });
  expect(update2.args.where.params).toEqual([2]);
  expect(update2.args.data).toMatchObject({ executed: 2, orderStatus: 2 });
  expect(insert.args.data).toMatchObject({ amount: 5, price: 9, orderType: 1, executed: 4, orderStatus: 1, userId: 1 });
});

// Limit sell with no matching bids
it('creates open limit sell when no bids exist', async () => {
  const trade = createTrade();
  qbMock.fetchAllResults.push({ results: [] });

  const res = await trade.placeNewOrder(3, 9, 1, 1);
  expect(res.affected).toEqual([]);
  expect(res.totalPrice).toBe(0);
  expect(res.statements.changes).toHaveLength(1);
  const [insert] = res.statements.changes;
  expect(insert.args.data).toMatchObject({ amount: 3, price: 9, orderType: 1, executed: 0, orderStatus: 1, userId: 1 });
});

// Limit buy fully filled immediately
it('executes limit buy completely with no open order', async () => {
  const trade = createTrade();
  qbMock.fetchAllResults.push({
    results: [
      { id: 1, amount: 5, executed: 0, price: 10, createdAt: 0, orderType: 1, userId: 2 },
    ],
  });

  const res = await trade.placeNewOrder(5, 10, 0, 1);
  expect(res.affected).toEqual([{ ownerId: 2, amount: 5, price: 10 }]);
  expect(res.totalPrice).toBe(50);
  expect(res.statements.changes).toHaveLength(2);
  const [insert, update] = res.statements.changes;
  expect(insert.args.data).toMatchObject({ amount: 5, price: 10, orderType: 0, executed: 5, orderStatus: 2, userId: 1 });
  expect(update.args.where.params).toEqual([1]);
  expect(update.args.data).toMatchObject({ executed: 5, orderStatus: 2 });
});

// Market buy with no available asks becomes open order
it('creates open market buy when no asks exist', async () => {
  const trade = createTrade();
  qbMock.fetchAllResults.push({ results: [] });

  const res = await trade.placeNewOrder(4, 0, 0, 1);
  expect(res.affected).toEqual([]);
  expect(res.totalPrice).toBe(0);
  expect(res.statements.changes).toHaveLength(1);
  const [insert] = res.statements.changes;
  expect(insert.args.data).toMatchObject({ amount: 4, price: 0, orderType: 0, executed: 0, orderStatus: 1, userId: 1 });
});

// Market sell with no available bids becomes open order
it('creates open market sell when no bids exist', async () => {
  const trade = createTrade();
  qbMock.fetchAllResults.push({ results: [] });

  const res = await trade.placeNewOrder(2, 0, 1, 1);
  expect(res.affected).toEqual([]);
  expect(res.totalPrice).toBe(0);
  expect(res.statements.changes).toHaveLength(1);
  const [insert] = res.statements.changes;
  expect(insert.args.data).toMatchObject({ amount: 2, price: 0, orderType: 1, executed: 0, orderStatus: 1, userId: 1 });
});

// Buy order rejected due to insufficient balance
it('rejects buy order when balance is insufficient', async () => {
  const trade = createTrade();
  const ws: any = { deserializeAttachment: () => ({ userId: 1 }), send: vi.fn() };
  qbMock.fetchOneResults.push({ results: { balance: '10', shares: 0 } });
  qbMock.fetchAllResults.push({ results: [] });

  await trade.webSocketMessage(ws, JSON.stringify({ reqType: 'newOrder', amount: 5, price: 3, type: 0 }));
  expect(ws.send).toHaveBeenCalledWith(JSON.stringify({ result: false, type: 'newOrder', data: 'insufficient balance' }));
});

// Sell order rejected when shares are insufficient
it('rejects sell order when shares are insufficient', async () => {
  const trade = createTrade();
  const ws: any = { deserializeAttachment: () => ({ userId: 1 }), send: vi.fn() };
  qbMock.fetchOneResults.push({ results: { balance: '200', shares: 1 } });
  qbMock.fetchAllResults.push({ results: [] });

  await trade.webSocketMessage(ws, JSON.stringify({ reqType: 'newOrder', amount: 3, price: 10, type: 1 }));
  expect(ws.send).toHaveBeenCalledWith(JSON.stringify({ result: false, type: 'newOrder', data: 'insufficient shares' }));
});

// Sell order rejected when balance for tax is insufficient
it('rejects sell order when balance is below tax', async () => {
  const trade = createTrade();
  const ws: any = { deserializeAttachment: () => ({ userId: 1 }), send: vi.fn() };
  qbMock.fetchOneResults.push({ results: { balance: '50', shares: 5 } });
  qbMock.fetchAllResults.push({ results: [] });

  await trade.webSocketMessage(ws, JSON.stringify({ reqType: 'newOrder', amount: 1, price: 9, type: 1 }));
  expect(ws.send).toHaveBeenCalledWith(JSON.stringify({ result: false, type: 'newOrder', data: 'insufficient balance for tax' }));
});

