import { describe, it, expect, beforeEach, vi } from 'vitest';
import Admin from '../src/libs/admin';
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

const ctx: any = { env: { TASK_DB: 'task', USER_DB: 'user' } };

beforeEach(() => {
  qbMock.reset();
  vi.clearAllMocks();
});

// getCurriculums
describe('Admin.getCurriculums', () => {
  it('throws for non admin', async () => {
    (checkAuth as any).mockResolvedValue({ isAdmin: 0 });
    const field = Admin.getCurriculums(t) as any;
    await expect(field.resolve(null, { jwtToken: 't' }, ctx)).rejects.toThrow(AppError.UN_AUTHED);
  });

  it('returns empty array when no results', async () => {
    (checkAuth as any).mockResolvedValue({ isAdmin: 1 });
    qbMock.fetchAllResults.push({ results: null });
    const field = Admin.getCurriculums(t)as any;
    const res = await field.resolve(null, { jwtToken: 't' }, ctx);
    expect(res).toEqual([]);
    expect(qbMock.ops[0].method).toBe('fetchAll');
  });

  it('maps database results', async () => {
    (checkAuth as any).mockResolvedValue({ isAdmin: 1 });
    qbMock.fetchAllResults.push({ results: [{ id: 1, name: 'c', countryId: 2, levelType: 0, semester: 1, level: 'A', completedPercent: 0, openToWork: 1 }] });
    const field = Admin.getCurriculums(t)as any;
    const res = await field.resolve(null, { jwtToken: 't' }, ctx);
    expect(res).toEqual([{ id: 1, name: 'c', countryId: 2, levelType: 0, semester: 1, level: 'A', completedPercent: 0, openToWork: 1 }]);
  });
});

// editOrAddCurriculum
describe('Admin.editOrAddCurriculum', () => {
  it('throws for non admin', async () => {
    (checkAuth as any).mockResolvedValue({ isAdmin: 0 });
    const field = Admin.editOrAddCurriculum(t)as any;
    await expect(field.resolve(null, { jwtToken: 't', id: 1, name: '', countryId: 1, levelType: 0, level: '', semester: 1, openToWork: 1 }, ctx)).rejects.toThrow(AppError.UN_AUTHED);
  });

  it('updates when id provided', async () => {
    (checkAuth as any).mockResolvedValue({ isAdmin: 1 });
    qbMock.updateResults.push({ success: true });
    const field = Admin.editOrAddCurriculum(t)as any;
    const args = { jwtToken: 't', id: 5, name: 'n', countryId: 1, levelType: 0, level: 'L', semester: 1, openToWork: 1 };
    const res = await field.resolve(null, args, ctx);
    expect(res).toBe(true);
    expect(qbMock.ops.find(o => o.method === 'update')).toBeTruthy();
  });

  it('inserts when id missing', async () => {
    (checkAuth as any).mockResolvedValue({ isAdmin: 1 });
    qbMock.insertResults.push({ success: true });
    const field = Admin.editOrAddCurriculum(t)as any;
    const args = { jwtToken: 't', name: 'n', countryId: 1, levelType: 0, level: 'L', semester: 1, openToWork: 1 };
    const res = await field.resolve(null, args, ctx);
    expect(res).toBe(true);
    expect(qbMock.ops.find(o => o.method === 'insert')).toBeTruthy();
  });
});

// getAllUsers
describe('Admin.getAllUsers', () => {
  it('throws for non admin', async () => {
    (checkAuth as any).mockResolvedValue({ isAdmin: 0 });
    const field = Admin.getAllUsers(t)as any;
    await expect(field.resolve(null, { jwtToken: 't' }, ctx)).rejects.toThrow(AppError.UN_AUTHED);
  });

  it('returns empty list for no data', async () => {
    (checkAuth as any).mockResolvedValue({ isAdmin: 1 });
    qbMock.fetchAllResults.push({ results: undefined });
    const field = Admin.getAllUsers(t)as any;
    const res = await field.resolve(null, { jwtToken: 't' }, ctx);
    expect(res).toEqual([]);
  });

  it('maps user data', async () => {
    (checkAuth as any).mockResolvedValue({ isAdmin: 1 });
    qbMock.fetchAllResults.push({ results: [{ id: 1, userName: 'u', loginType: 0, loginInfo: 'e', country: 1, time: 0, balance: '0', shares: 0, trustPoint: 0, balanceToBuyShare: '0', distributePercent: 0, isAdmin: 1, adminPrivileges: 0 }] });
    const field = Admin.getAllUsers(t)as any;
    const res = await field.resolve(null, { jwtToken: 't' }, ctx);
    expect(res).toEqual([{ id: 1, userName: 'u', loginType: 0, loginInfo: 'e', country: 1, time: 0, balance: '0', shares: 0, trustPoint: 0, balanceToBuyShare: '0', distributePercent: 0, isAdmin: 1, adminPrivileges: 0 }]);
  });
});

// createTask
describe('Admin.createTask', () => {
  it('throws for non admin', async () => {
    (checkAuth as any).mockResolvedValue({ isAdmin: 0 });
    const field = Admin.createTask(t)as any;
    await expect(field.resolve(null, { jwtToken: 't', curriculumId: 1, shares: 1, parentId: 0, taskName: '', taskType: 0, reDoIt: 0, access: 0 }, ctx)).rejects.toThrow(AppError.UN_AUTHED);
  });

  it('updates existing task', async () => {
    (checkAuth as any).mockResolvedValue({ isAdmin: 1 });
    qbMock.updateResults.push({ success: true });
    const field = Admin.createTask(t)as any;
    const args = { jwtToken: 't', taskId: 2, status: 1, curriculumId: 1, shares: 3, parentId: 0, taskName: 't', taskType: 0, reDoIt: 0, access: 1 };
    const res = await field.resolve(null, args, ctx);
    expect(res).toBe(true);
    expect(qbMock.ops.find(o => o.method === 'update')).toBeTruthy();
  });

  it('creates new task', async () => {
    (checkAuth as any).mockResolvedValue({ isAdmin: 1 });
    qbMock.insertResults.push({ success: true });
    const field = Admin.createTask(t)as any;
    const args = { jwtToken: 't', curriculumId: 1, shares: 3, parentId: 0, taskName: 't', taskType: 0, reDoIt: 0, access: 1 };
    const res = await field.resolve(null, args, ctx);
    expect(res).toBe(true);
    expect(qbMock.ops.find(o => o.method === 'insert')).toBeTruthy();
  });
});

// getTasks
describe('Admin.getTasks', () => {
  it('throws for non admin', async () => {
    (checkAuth as any).mockResolvedValue({ isAdmin: 0 });
    const field = Admin.getTasks(t)as any;
    await expect(field.resolve(null, { jwtToken: 't', curriculumId: 1 }, ctx)).rejects.toThrow(AppError.UN_AUTHED);
  });

  it('returns empty list when no tasks', async () => {
    (checkAuth as any).mockResolvedValue({ isAdmin: 1 });
    qbMock.fetchAllResults.push({ results: [] });
    const field = Admin.getTasks(t)as any;
    const res = await field.resolve(null, { jwtToken: 't', curriculumId: 1 }, ctx);
    expect(res).toEqual([]);
  });

  it('maps tasks data', async () => {
    (checkAuth as any).mockResolvedValue({ isAdmin: 1 });
    qbMock.fetchAllResults.push({ results: [{ id: 1, time: 0, shares: 1, taskType: 0, taskName: 'n', curriculumId: 1, parentId: 0, status: 0, occupied: 0, occupiedTime: 0, reDoIt: 0, reDoItNum: 0, access: 1 }] });
    const field = Admin.getTasks(t)as any;
    const res = await field.resolve(null, { jwtToken: 't', curriculumId: 1 }, ctx);
    expect(res).toEqual([{ id: 1, time: 0, shares: 1, taskType: 0, taskName: 'n', curriculumId: 1, parentId: 0, status: 0, occupied: 0, occupiedTime: 0, reDoIt: 0, reDoItNum: 0, access: 1 }]);
  });
});

// submitShares
describe('Admin.submitShares', () => {
  it('throws for non admin', async () => {
    (checkAuth as any).mockResolvedValue({ isAdmin: 0 });
    const field = Admin.submitShares(t)as any;
    await expect(field.resolve(null, { jwtToken: 't', curriculumId: 1, taskId: 1, data: '[]' }, ctx)).rejects.toThrow(AppError.UN_AUTHED);
  });

  it('processes share data', async () => {
    (checkAuth as any).mockResolvedValue({ isAdmin: 1 });
    qbMock.fetchOneResults.push({ results: { trustPoint: 5, shares: 10 } });
    qbMock.fetchOneResults.push({ results: null });
    qbMock.updateResults.push({ success: true }); // userTask update
    qbMock.insertResults.push({ success: true }); // shares insert
    qbMock.updateResults.push({ success: true }); // user update
    const field = Admin.submitShares(t)as any;
    const data = JSON.stringify([{ id: 1, shares: 2, taskShare: 4 }, { id: 2, shares: 1, taskShare: 3 }]);
    const res = await field.resolve(null, { jwtToken: 't', curriculumId: 1, taskId: 1, data }, ctx);
    expect(res).toBe(true);
    expect(qbMock.ops.filter(o => o.method === 'update').length).toBe(2);
    expect(qbMock.ops.filter(o => o.method === 'insert').length).toBe(1);
  });
});
