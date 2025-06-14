import { describe, it, expect, beforeEach, afterEach, vi } from 'vitest';
import Shares from '../src/libs/shares';
import AppError from '../src/utils/error';
import { checkAuth } from '../src/utils/check_auth';
import { GraphQLError } from 'graphql/error';

vi.mock('../src/utils/check_auth', () => ({ checkAuth: vi.fn() }));

const qbMock = {
  ops: [] as any[],
  fetchAllResults: [] as any[],
  fetchOneResults: [] as any[],
  insertResults: [] as any[],
  updateResults: [] as any[],
  reset() {
    this.ops = [];
    this.fetchAllResults = [];
    this.fetchOneResults = [];
    this.insertResults = [];
    this.updateResults = [];
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
      const res = qbMock.insertResults.shift() ?? { success: true };
      return { execute: async () => res };
    }
    update(args: any) {
      qbMock.ops.push({ method: 'update', db: this.db, args });
      const res = qbMock.updateResults.shift() ?? { success: true };
      return { execute: async () => res };
    }
  }
  return { D1QB };
});

const t: any = {
  arg: {
    string: () => ({}),
    int: () => ({}),
  },
  field: (opts: any) => opts,
};

const ctx: any = {
  env: {
    USER_DB: 'user',
    STATISTICS_DB: 'stat',
    PROFIT_DB: 'profit',
    SNAPSHOT_DB: 'snap',
    TASK_DB: 'task',
  },
};

beforeEach(() => {
  qbMock.reset();
  vi.clearAllMocks();
});

afterEach(() => {
  qbMock.reset();
});

// getBalanceData default
describe('Shares.getBalanceData', () => {
  it('returns default values when no records', async () => {
    (checkAuth as any).mockResolvedValue({ id: 1 });
    const field = Shares.getBalanceData(t) as any;
    const res = await field.resolve(null, { jwtToken: 't' }, ctx);
    expect(res).toEqual({ balance: '', shares: 0, totalShares: 0, statistics: [], distruibutedProfit: [], sharesData: [] });
    expect(qbMock.ops.filter(o => o.method === 'fetchOne').length).toBe(2);
  });

  it('aggregates balance data', async () => {
    (checkAuth as any).mockResolvedValue({ id: 2 });
    const now = Date.now();
    const oldStat = now - 2 * 24 * 60 * 60 * 1000;

    qbMock.fetchOneResults.push({ results: { balance: '10', shares: 5 } });
    qbMock.fetchOneResults.push({ results: { totalShares: 20 } });

    qbMock.fetchAllResults.push({ results: [{ createdAt: oldStat, price: 1 }] });
    qbMock.fetchAllResults.push({ results: [{ price: 2 }] });
    qbMock.insertResults.push({ success: true });

    qbMock.fetchAllResults.push({ results: [{ id: 7, createdAt: now - 1000, amount: '3', amountInfo: 'i' }] });
    qbMock.fetchAllResults.push({ results: [{ createdAt: now - 500, balance: 4 }] });
    qbMock.fetchAllResults.push({ results: [{ createdAt: now - 2000, balance: 1 }] });

    qbMock.fetchAllResults.push({ results: [{ id: 9, createdAt: now - 3000, taskId: 5, amount: 6, source: 1 }] });

    const field = Shares.getBalanceData(t) as any;
    const res = await field.resolve(null, { jwtToken: 't' }, ctx);
    expect(res.balance).toBe('10');
    expect(res.shares).toBe(5);
    expect(res.totalShares).toBe(20);
    expect(res.statistics.length).toBe(2);
    expect(res.distruibutedProfit).toEqual([
      { id: 7, createdAt: now - 1000, amount: '3', amountInfo: 'i', userShare: 1 },
    ]);
    expect(res.sharesData).toEqual([
      { id: 9, createdAt: now - 3000, taskId: 5, amount: 6, source: 1 },
    ]);
    expect(qbMock.ops.some(o => o.method === 'insert' && o.db === 'stat')).toBe(true);
  });
});

// getbalanceWithHistory
describe('Shares.getbalanceWithHistory', () => {
  it('returns balance with history', async () => {
    (checkAuth as any).mockResolvedValue({ id: 3 });
    qbMock.fetchOneResults.push({ results: { balance: '2', shares: 1 } });
    qbMock.fetchAllResults.push({ results: [{ id: 1, createdAt: 1, amount: 2, price: 3, orderType: 0, orderStatus: 0, executed: 1 }] });
    const field = Shares.getbalanceWithHistory(t) as any;
    const res = await field.resolve(null, { jwtToken: 't' }, ctx);
    expect(res).toEqual({ balance: '2', shares: 1, history: [{ id: 1, createdAt: 1, amount: 2, price: 3, orderType: 0, orderStatus: 0, executed: 1 }] });
  });

  it('returns defaults when no data', async () => {
    (checkAuth as any).mockResolvedValue({ id: 4 });
    const field = Shares.getbalanceWithHistory(t) as any;
    const res = await field.resolve(null, { jwtToken: 't' }, ctx);
    expect(res).toEqual({ balance: '0', shares: 0, history: [] });
  });
});

// getShareInfo
describe('Shares.getShareInfo', () => {
  it('throws when share not found', async () => {
    (checkAuth as any).mockResolvedValue({});
    const field = Shares.getShareInfo(t) as any;
    await expect(field.resolve(null, { jwtToken: 't', shareId: 5 }, ctx)).rejects.toThrow(AppError.UNKNOW_ERROR);
  });

  it('returns share info', async () => {
    (checkAuth as any).mockResolvedValue({});
    qbMock.fetchOneResults.push({ results: { time: 1, shares: 2, userTaskName: 'n', level: 'L', curriculum: 'c' } });
    const field = Shares.getShareInfo(t) as any;
    const res = await field.resolve(null, { jwtToken: 't', shareId: 1 }, ctx);
    expect(res).toEqual({ time: 1, shares: 2, userTaskName: 'n', level: 'L', curriculum: 'c' });
  });
});
