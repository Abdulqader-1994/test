import { describe, it, expect, beforeEach, vi } from 'vitest';
import Study from '../src/libs/study';
import { checkAuth } from '../src/utils/check_auth';

vi.mock('../src/utils/check_auth', () => ({ checkAuth: vi.fn() }));

const qbMock = {
  ops: [] as any[],
  fetchAllResults: [] as any[],
  reset() {
    this.ops = [];
    this.fetchAllResults = [];
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

const ctx: any = { env: { TASK_DB: 'task' } };

beforeEach(() => {
  qbMock.reset();
  vi.clearAllMocks();
});

describe('Study.getSubscribedMaterials', () => {
  it('returns empty array when no results', async () => {
    (checkAuth as any).mockResolvedValue({ id: 1 });
    qbMock.fetchAllResults.push({ results: undefined });
    const field = Study.getSubscribedMaterials(t) as any;
    const res = await field.resolve(null, { jwtToken: 't' }, ctx);
    expect(res).toEqual([]);
    expect(qbMock.ops[0].method).toBe('fetchAll');
  });

  it('maps subscribed materials data', async () => {
    (checkAuth as any).mockResolvedValue({ id: 2 });
    qbMock.fetchAllResults.push({
      results: [
        { id: 1, createdAt: 0, name: 'c', countryId: 1, levelType: 0, level: 'L', semester: 1, finished: 'f', purchased: 1 }
      ]
    });
    const field = Study.getSubscribedMaterials(t) as any;
    const res = await field.resolve(null, { jwtToken: 't' }, ctx);
    expect(res).toEqual([
      { id: 1, createdAt: 0, name: 'c', countryId: 1, levelType: 0, level: 'L', semester: 1, finished: 'f', purchased: 1 }
    ]);
  });
});

describe('Study.getMaterials', () => {
  it('returns empty array when no results', async () => {
    (checkAuth as any).mockResolvedValue({ id: 3 });
    qbMock.fetchAllResults.push({ results: [] });
    const field = Study.getMaterials(t) as any;
    const res = await field.resolve(null, { jwtToken: 't' }, ctx);
    expect(res).toEqual([]);
    expect(qbMock.ops[0].method).toBe('fetchAll');
  });

  it('maps curriculum data', async () => {
    (checkAuth as any).mockResolvedValue({ id: 4 });
    qbMock.fetchAllResults.push({
      results: [
        { id: 1, name: 'c', countryId: 1, levelType: 0, semester: 1, level: 'L', completedPercent: 0, openToWork: 1 }
      ]
    });
    const field = Study.getMaterials(t) as any;
    const res = await field.resolve(null, { jwtToken: 't' }, ctx);
    expect(res).toEqual([
      { id: 1, name: 'c', countryId: 1, levelType: 0, semester: 1, level: 'L', completedPercent: 0, openToWork: 1 }
    ]);
  });
});
