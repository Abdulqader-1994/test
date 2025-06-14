import { describe, it, expect, beforeEach, vi } from 'vitest';
import Work from '../src/libs/work';
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

const durableResults: any[] = [];
const durableMock = {
  resetTasks: vi.fn(async () => {}),
  doTask: vi.fn(async () => JSON.stringify(durableResults.shift() ?? {})),
};

const ctx: any = {
  env: {
    TASK_DB: 'task',
    USER_DB: 'user',
    TASK_LAB: {
      idFromName: vi.fn((n: string) => n),
      get: vi.fn(() => durableMock),
    },
    DATA: {
      store: {} as Record<string, string>,
      async get(key: string) { return this.store[key] ?? null; },
      async put(key: string, val: string) { this.store[key] = val; },
    },
  },
};

const t: any = {
  arg: { string: () => ({}), int: () => ({}) },
  field: (opts: any) => opts,
};

beforeEach(() => {
  qbMock.reset();
  durableResults.length = 0;
  Object.keys(ctx.env.DATA.store).forEach(k => delete ctx.env.DATA.store[k]);
  vi.clearAllMocks();
});

// getCurriculums
describe('Work.getCurriculums', () => {
  it('throws ZERO_TRUST for users without trust', async () => {
    (checkAuth as any).mockResolvedValue({ id: 1, isAdmin: 0 });
    qbMock.fetchOneResults.push({ results: { trustPoint: 0 } });
    const field = Work.getCurriculums(t) as any;
    await expect(field.resolve(null, { jwtToken: 't' }, ctx)).rejects.toThrow(AppError.ZERO_TRUST);
  });

  it('returns empty list when no data', async () => {
    (checkAuth as any).mockResolvedValue({ id: 1, isAdmin: 1 });
    qbMock.fetchAllResults.push({ results: null });
    const field = Work.getCurriculums(t) as any;
    const res = await field.resolve(null, { jwtToken: 't' }, ctx);
    expect(res).toEqual([]);
  });

  it('maps returned rows', async () => {
    (checkAuth as any).mockResolvedValue({ id: 1, isAdmin: 1 });
    qbMock.fetchAllResults.push({ results: [{ id: 1, name: 'c', countryId: 2, levelType: 0, level: 'L', semester: 1, completedPercent: 50, openToWork: 1 }] });
    const field = Work.getCurriculums(t) as any;
    const res = await field.resolve(null, { jwtToken: 't' }, ctx);
    expect(res).toEqual([{ id: 1, name: 'c', countryId: 2, levelType: 0, level: 'L', semester: 1, completedPercent: 50, openToWork: 1 }]);
  });
});

// getActiveTasks
describe('Work.getActiveTasks', () => {
  it('throws WRONG_DATA when user has zero trust', async () => {
    (checkAuth as any).mockResolvedValue({ id: 2, isAdmin: 0 });
    qbMock.fetchOneResults.push({ results: { trustPoint: 0 } });
    const field = Work.getActiveTasks(t) as any;
    await expect(field.resolve(null, { jwtToken: 't', curriculumId: 1 }, ctx)).rejects.toThrow(AppError.WRONG_DATA);
  });

  it('returns tasks for admin user', async () => {
    (checkAuth as any).mockResolvedValue({ id: 2, isAdmin: 1 });
    qbMock.fetchAllResults.push({ results: [{ id: 1, time: 0, shares: 1, taskName: 't', taskType: 0, curriculumId: 1, parentId: 0, status: 0, occupied: 0, occupiedTime: null, reDoIt: 0, reDoItNum: 0, access: 0 }] });
    const field = Work.getActiveTasks(t) as any;
    const res = await field.resolve(null, { jwtToken: 't', curriculumId: 1 }, ctx);
    expect(res.length).toBe(1);
    expect(res[0].id).toBe(1);
  });

  it('fetches status=1 tasks for normal user', async () => {
    (checkAuth as any).mockResolvedValue({ id: 3, isAdmin: 0 });
    qbMock.fetchOneResults.push({ results: { trustPoint: 5 } });
    qbMock.fetchAllResults.push({ results: [{ id: 2, userTaskId: null, time: 0, shares: 1, taskName: 't', taskType: 0, curriculumId: 1, parentId: 0, status: 1, occupied: 0, occupiedTime: null, reDoIt: 0, reDoItNum: 0, access: 0 }] });
    const field = Work.getActiveTasks(t) as any;
    const res = await field.resolve(null, { jwtToken: 't', curriculumId: 1 }, ctx);
    expect(res.length).toBe(1);
    expect(durableMock.resetTasks).toHaveBeenCalled();
  });

  it('second query when first empty', async () => {
    (checkAuth as any).mockResolvedValue({ id: 3, isAdmin: 0 });
    qbMock.fetchOneResults.push({ results: { trustPoint: 5 } });
    qbMock.fetchAllResults.push({ results: [] });
    qbMock.fetchAllResults.push({ results: [{ id: 3, userTaskId: null, time: 0, shares: 1, taskName: 't', taskType: 0, curriculumId: 1, parentId: 0, status: 0, occupied: 0, occupiedTime: null, reDoIt: 0, reDoItNum: 0, access: 0 }] });
    const field = Work.getActiveTasks(t) as any;
    const res = await field.resolve(null, { jwtToken: 't', curriculumId: 1 }, ctx);
    expect(res.length).toBe(1);
  });
});

// getDoneTasks
describe('Work.getDoneTasks', () => {
  it('returns empty when no tasks', async () => {
    (checkAuth as any).mockResolvedValue({ id: 1 });
    qbMock.fetchAllResults.push({ results: null });
    const field = Work.getDoneTasks(t) as any;
    const res = await field.resolve(null, { jwtToken: 't' }, ctx);
    expect(res).toEqual([]);
  });

  it('maps task rows', async () => {
    (checkAuth as any).mockResolvedValue({ id: 1 });
    qbMock.fetchAllResults.push({ results: [{ id: 1, curriculumId: 1, taskId: 2, time: 0, shares: 1, userTaskName: 'u', doItNum: 0, status: 0, level: 'L', name: 'c', userShare: 2 }] });
    const field = Work.getDoneTasks(t) as any;
    const res = await field.resolve(null, { jwtToken: 't' }, ctx);
    expect(res[0].curriculum).toBe('c');
  });
});

// doTask
describe('Work.doTask', () => {
  it('throws TASK_UNAVAILABLE', async () => {
    (checkAuth as any).mockResolvedValue({ id: 1, isAdmin: 1 });
    durableResults.push({ result: -1 });
    const field = Work.doTask(t) as any;
    await expect(field.resolve(null, { taskId: 1, curriculumId: 1, jwtToken: 't' }, ctx)).rejects.toThrow(AppError.TASK_UNAVAILABLE);
  });

  it('throws DO_YOUR_TASK', async () => {
    (checkAuth as any).mockResolvedValue({ id: 1, isAdmin: 1 });
    durableResults.push({ result: -2 });
    const field = Work.doTask(t) as any;
    await expect(field.resolve(null, { taskId: 1, curriculumId: 1, jwtToken: 't' }, ctx)).rejects.toThrow(AppError.DO_YOUR_TASK);
  });

  it('records user task and trust for normal user', async () => {
    (checkAuth as any).mockResolvedValue({ id: 2, isAdmin: 0 });
    durableResults.push({ result: 1, reDoItNum: 1, shares: 5 });
    qbMock.fetchOneResults.push({ results: { trustPoint: 4 } });
    const field = Work.doTask(t) as any;
    ctx.env.DATA.store['1-1-0'] = 'a';
    ctx.env.DATA.store['1-1-1'] = 'b';
    const res = await field.resolve(null, { taskId: 1, curriculumId: 1, jwtToken: 't' }, ctx);
    expect(qbMock.ops.find(o => o.method === 'insert' && o.db === 'task')).toBeTruthy();
    expect(qbMock.ops.find(o => o.method === 'update' && o.db === 'user')).toBeTruthy();
    expect(res).toEqual(['a', 'b']);
  });

  it('skips trust update for admin', async () => {
    (checkAuth as any).mockResolvedValue({ id: 2, isAdmin: 1 });
    durableResults.push({ result: 1, reDoItNum: 0, shares: 5 });
    const field = Work.doTask(t) as any;
    await field.resolve(null, { taskId: 1, curriculumId: 1, jwtToken: 't' }, ctx);
    expect(qbMock.ops.find(o => o.method === 'update' && o.db === 'user')).toBeUndefined();
  });
});

// submitTask
describe('Work.submitTask', () => {
  it('throws UNKNOW_ERROR when task missing', async () => {
    (checkAuth as any).mockResolvedValue({ id: 3 });
    qbMock.fetchOneResults.push({ results: undefined });
    const field = Work.submitTask(t) as any;
    await expect(field.resolve(null, { taskId: 1, curriculumId: 1, jwtToken: 't', data: '{}' }, ctx)).rejects.toThrow(AppError.UNKNOW_ERROR);
  });

  it('throws TASK_TIME_EXCEEDED', async () => {
    (checkAuth as any).mockResolvedValue({ id: 3 });
    qbMock.fetchOneResults.push({ results: { occupiedTime: 0, shares: 0 } });
    const field = Work.submitTask(t) as any;
    await expect(field.resolve(null, { taskId: 1, curriculumId: 1, jwtToken: 't', data: '{}' }, ctx)).rejects.toThrow(AppError.TASK_TIME_EXCEEDED);
  });

  it('handles first submit', async () => {
    (checkAuth as any).mockResolvedValue({ id: 3 });
    qbMock.fetchOneResults.push({ results: { occupiedTime: Date.now(), shares: 5, reDoItNum: 0, status: 0 } });
    const field = Work.submitTask(t) as any;
    const res = await field.resolve(null, { taskId: 1, curriculumId: 1, jwtToken: 't', data: 'd' }, ctx);
    expect(res).toBe(true);
    expect(ctx.env.DATA.store['1-1-0']).toBe('d');
  });

  it('handles verify submit', async () => {
    (checkAuth as any).mockResolvedValue({ id: 3 });
    qbMock.fetchOneResults.push({ results: { occupiedTime: Date.now(), shares: 5, reDoItNum: 0, status: 1, reDoIt: 2 } });
    const field = Work.submitTask(t) as any;
    const res = await field.resolve(null, { taskId: 1, curriculumId: 1, jwtToken: 't', data: 'd' }, ctx);
    expect(res).toBe(true);
  });

  it('admin verify final', async () => {
    (checkAuth as any).mockResolvedValue({ id: 3 });
    qbMock.fetchOneResults.push({ results: { occupiedTime: Date.now(), shares: 5, reDoItNum: 0, status: 2, taskType: 0 } });
    const field = Work.submitTask(t) as any;
    const res = await field.resolve(null, { taskId: 1, curriculumId: 1, jwtToken: 't', data: '{"map":1}' }, ctx);
    expect(res).toBe(true);
    expect(ctx.env.DATA.store['1-index']).toBe('1');
  });
});
