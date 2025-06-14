import { describe, it, expect, beforeEach, afterEach, vi } from 'vitest';
import { TaskLab } from '../src/durable/task';
import { BackeEndEnv } from '../src/graphql/builder';

vi.mock('cloudflare:workers', () => ({
  DurableObject: class {
    state: any;
    env: any;
    ctx: any;
    constructor(state: any, env: any) { this.state = state; this.env = env; this.ctx = state; }
  }
}));

const qbMock = {
  ops: [] as any[],
  fetchOneResults: [] as any[],
  updateResults: [] as any[],
  reset() {
    this.ops = [];
    this.fetchOneResults = [];
    this.updateResults = [];
  },
};

vi.mock('workers-qb', () => {
  class D1QB {
    db: string;
    constructor(db: string) { this.db = db; }
    fetchOne(args: any) {
      qbMock.ops.push({ method: 'fetchOne', db: this.db, args });
      const res = qbMock.fetchOneResults.shift() ?? { success: true, results: undefined };
      return { execute: async () => res };
    }
    update(args: any) {
      qbMock.ops.push({ method: 'update', db: this.db, args });
      const res = qbMock.updateResults.shift() ?? { success: true, results: [] };
      return { execute: async () => res };
    }
  }
  return { D1QB };
});

let storage: Record<string, any>;
let state: any;
let env: BackeEndEnv;

beforeEach(() => {
  qbMock.reset();
  storage = {};
  state = {
    storage: {
      get: vi.fn(async (k: string) => storage[k]),
      put: vi.fn(async (k: string, v: any) => { storage[k] = v; }),
      deleteAll: vi.fn(async () => { storage = {}; }),
    },
    blockConcurrencyWhile: async (fn: any) => await fn(),
  };
  env = { TASK_DB: 'task' } as unknown as BackeEndEnv;
  vi.useFakeTimers();
  vi.setSystemTime(0);
});

// resetTasks
describe('TaskLab.resetTasks', () => {
  it('skips update when called within an hour', async () => {
    const lab = new TaskLab(state, env);
    vi.setSystemTime(1800000); // 30 minutes
    await lab.resetTasks();
    expect(qbMock.ops.find(o => o.method === 'update')).toBeUndefined();
  });

  it('updates tasks when an hour has passed', async () => {
    const lab = new TaskLab(state, env);
    vi.setSystemTime(3600001);
    qbMock.updateResults.push({ success: true, results: [] });
    await lab.resetTasks();
    expect(qbMock.ops.find(o => o.method === 'update')).toBeTruthy();
    expect(storage['lastCheck']).toBe(3600001);
  });
});

// doTask
describe('TaskLab.doTask', () => {
  it('returns 0 for re-entered task', async () => {
    const lab = new TaskLab(state, env);
    qbMock.fetchOneResults.push({ results: { occupied: 1, reDoItNum: 2 } });
    const res = await lab.doTask(5, 1);
    expect(JSON.parse(res)).toEqual({ result: 0, reDoItNum: 2 });
  });

  it('returns -1 when task occupied by another', async () => {
    const lab = new TaskLab(state, env);
    qbMock.fetchOneResults.push({ results: { occupied: 2 } });
    const res = await lab.doTask(5, 1);
    expect(JSON.parse(res)).toEqual({ result: -1 });
  });

  it('returns -2 when user already has a task', async () => {
    const lab = new TaskLab(state, env);
    qbMock.fetchOneResults.push({ results: undefined });
    qbMock.fetchOneResults.push({ results: { id: 99 } });
    const res = await lab.doTask(5, 1);
    expect(JSON.parse(res)).toEqual({ result: -2 });
  });

  it('occupies task and returns details', async () => {
    const lab = new TaskLab(state, env);
    qbMock.fetchOneResults.push({ results: undefined });
    qbMock.fetchOneResults.push({ results: null });
    qbMock.updateResults.push({ results: [{ shares: 3, taskName: 'n', reDoItNum: 0 }] });
    const res = await lab.doTask(5, 1);
    expect(JSON.parse(res)).toEqual({ result: 1, shares: 3, taskName: 'n', reDoItNum: 0 });
    expect(qbMock.ops.find(o => o.method === 'update')).toBeTruthy();
  });
});

describe('TaskLab.deleteAll', () => {
  it('clears storage', async () => {
    const lab = new TaskLab(state, env);
    storage['k'] = 'v';
    await lab.deleteAll();
    expect(storage).toEqual({});
  });
});

afterEach(() => {
  vi.useRealTimers();
});

