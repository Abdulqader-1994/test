import { describe, it, expect, beforeEach, vi } from 'vitest';
import User from '../src/libs/user';
import AppError from '../src/utils/error';
import { checkAuth } from '../src/utils/check_auth';

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
      const res = qbMock.insertResults.shift() ?? { success: true, results: {} };
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

const ctx: any = { env: { USER_DB: 'user', TRANSECTION_DB: 'transection' } };

beforeEach(() => {
  qbMock.reset();
  vi.clearAllMocks();
});

// updateUserName
describe('User.updateUserName', () => {
  it('throws for short username', async () => {
    const field = User.updateUserName(t) as any;
    await expect(field.resolve(null, { jwtToken: 't', newUsername: 'abc' }, ctx)).rejects.toThrow(AppError.USERNAME_CHARS_MIN);
  });

  it('throws when username exists', async () => {
    (checkAuth as any).mockResolvedValue({ id: 1 });
    qbMock.fetchOneResults.push({ results: { id: 2 } });
    const field = User.updateUserName(t) as any;
    await expect(field.resolve(null, { jwtToken: 't', newUsername: 'admin1' }, ctx)).rejects.toThrow(AppError.DATA_EXIST);
  });

  it('throws on update failure', async () => {
    (checkAuth as any).mockResolvedValue({ id: 1 });
    qbMock.fetchOneResults.push({ results: null });
    qbMock.updateResults.push({ success: false });
    const field = User.updateUserName(t) as any;
    await expect(field.resolve(null, { jwtToken: 't', newUsername: 'userone' }, ctx)).rejects.toThrow(AppError.UNKNOW_ERROR);
  });

  it('updates username', async () => {
    (checkAuth as any).mockResolvedValue({ id: 1 });
    qbMock.fetchOneResults.push({ results: null });
    qbMock.updateResults.push({ success: true });
    const field = User.updateUserName(t) as any;
    const res = await field.resolve(null, { jwtToken: 't', newUsername: 'userone' }, ctx);
    expect(res).toBe(true);
    expect(qbMock.ops.find(o => o.method === 'update')).toBeTruthy();
  });
});

// updateDistributePercent
describe('User.updateDistributePercent', () => {
  it('updates value', async () => {
    (checkAuth as any).mockResolvedValue({ id: 2 });
    qbMock.updateResults.push({ success: true });
    const field = User.updateDistributePercent(t) as any;
    const res = await field.resolve(null, { jwtToken: 't', newVal: 4 }, ctx);
    expect(res).toBe(true);
    expect(qbMock.ops[0].method).toBe('update');
    expect(qbMock.ops[0].db).toBe('user');
  });
});

// convertBuyShareToBalance
describe('User.convertBuyShareToBalance', () => {
  it('throws when user missing', async () => {
    (checkAuth as any).mockResolvedValue({ id: 3 });
    qbMock.fetchOneResults.push({ results: undefined });
    const field = User.convertBuyShareToBalance(t) as any;
    await expect(field.resolve(null, { jwtToken: 't' }, ctx)).rejects.toThrow(AppError.UNKNOW_ERROR);
  });

  it('converts balance', async () => {
    (checkAuth as any).mockResolvedValue({ id: 3 });
    qbMock.fetchOneResults.push({ results: { balance: '10.00', balanceToBuyShare: '5.00' } });
    qbMock.updateResults.push({ success: true });
    const field = User.convertBuyShareToBalance(t) as any;
    const res = await field.resolve(null, { jwtToken: 't' }, ctx);
    expect(res).toBe('15.00');
    expect(qbMock.ops.find(o => o.method === 'update')).toBeTruthy();
  });
});

// getTransections
describe('User.getTransections', () => {
  it('returns empty list when none', async () => {
    (checkAuth as any).mockResolvedValue({ id: 4 });
    qbMock.fetchAllResults.push({ results: null });
    const field = User.getTransections(t) as any;
    const res = await field.resolve(null, { jwtToken: 't', offset: 0 }, ctx);
    expect(res).toEqual([]);
    expect(qbMock.ops[0].method).toBe('fetchAll');
  });

  it('maps results', async () => {
    (checkAuth as any).mockResolvedValue({ id: 4 });
    qbMock.fetchAllResults.push({ results: [{ id: 1, userId: 4, amount: '1', currencyInfo: 'USD', time: 10, provider: 'p', type: 1 }] });
    const field = User.getTransections(t) as any;
    const res = await field.resolve(null, { jwtToken: 't', offset: 0 }, ctx);
    expect(res).toEqual([{ id: 1, userId: 4, amount: '1', currencyInfo: 'USD', time: 10, provider: 'p', type: 1 }]);
  });
});
