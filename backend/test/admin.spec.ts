import { describe, it, expect, vi, beforeEach } from 'vitest';
import Admin from '../src/libs/admin';
import * as CheckAuth from '../src/utils/check_auth';
import { D1QB } from 'workers-qb';

vi.mock('../src/utils/check_auth', () => ({
  checkAuth: vi.fn(),
}));

vi.mock('workers-qb', () => ({
  D1QB: vi.fn(),
}));

const mockFieldBuilder = { field: (opts: any) => opts, arg: { string: () => ({}), int: () => ({}) } } as any;

describe('Admin resolvers', () => {
  const env = { USER_DB: {}, TASK_DB: {} } as any;

  beforeEach(() => {
    vi.clearAllMocks();
  });

  it('getCurriculums returns list for admin', async () => {
    const { checkAuth } = CheckAuth as any;
    checkAuth.mockResolvedValueOnce({ isAdmin: true });

    const records = [{ id: 1, name: 'c', countryId: 1, levelType: 1, level: 'L', semester: 1, completedPercent: 0, openToWork: 1 }];
    (D1QB as any).mockImplementationOnce(() => {
      return {
        fetchAll: vi.fn().mockReturnThis(),
        fetchOne: vi.fn().mockReturnThis(),
        insert: vi.fn().mockReturnThis(),
        update: vi.fn().mockReturnThis(),
        execute: vi.fn().mockResolvedValue({ results: records }),
      };
    });

    const { resolve } = Admin.getCurriculums(mockFieldBuilder) as any;
    const result = await resolve({}, { jwtToken: 't' }, { env });
    expect(result).toEqual(records);
  });

  it('getCurriculums fails for non admin', async () => {
    const { checkAuth } = CheckAuth as any;
    checkAuth.mockResolvedValueOnce({ isAdmin: false });
    const { resolve } = Admin.getCurriculums(mockFieldBuilder) as any;
    await expect(resolve({}, { jwtToken: 't' }, { env })).rejects.toThrow('UN_AUTHED');
  });

  it('editOrAddCurriculum updates when id provided', async () => {
    const { checkAuth } = CheckAuth as any;
    checkAuth.mockResolvedValueOnce({ isAdmin: true });
    const update = vi.fn().mockReturnThis();
    const execute = vi.fn().mockResolvedValue({});
    (D1QB as any).mockImplementationOnce(() => ({
      fetchAll: vi.fn(),
      fetchOne: vi.fn(),
      insert: vi.fn(),
      update,
      execute,
    }));
    const { resolve } = Admin.editOrAddCurriculum(mockFieldBuilder) as any;
    const res = await resolve({}, { id: 5, name: 'n', countryId: 1, levelType: 1, level: 'l', semester: 1, openToWork: 1, jwtToken: 't' }, { env });
    expect(res).toBe(true);
    expect(update).toHaveBeenCalled();
    expect(execute).toHaveBeenCalled();
  });

  it('editOrAddCurriculum inserts when no id', async () => {
    const { checkAuth } = CheckAuth as any;
    checkAuth.mockResolvedValueOnce({ isAdmin: true });
    const insert = vi.fn().mockReturnThis();
    const execute = vi.fn().mockResolvedValue({});
    (D1QB as any).mockImplementationOnce(() => ({
      fetchAll: vi.fn(),
      fetchOne: vi.fn(),
      insert,
      update: vi.fn(),
      execute,
    }));
    const { resolve } = Admin.editOrAddCurriculum(mockFieldBuilder) as any;
    const res = await resolve({}, { name: 'n', countryId: 1, levelType: 1, level: 'l', semester: 1, openToWork: 1, jwtToken: 't' }, { env });
    expect(res).toBe(true);
    expect(insert).toHaveBeenCalled();
  });

  it('editOrAddCurriculum unauthorized', async () => {
    const { checkAuth } = CheckAuth as any;
    checkAuth.mockResolvedValueOnce({ isAdmin: false });
    const { resolve } = Admin.editOrAddCurriculum(mockFieldBuilder) as any;
    await expect(resolve({}, { name: 'n', countryId: 1, levelType: 1, level: 'l', semester: 1, openToWork: 1, jwtToken: 't' }, { env })).rejects.toThrow('UN_AUTHED');
  });

  it('getAllUsers returns data', async () => {
    const { checkAuth } = CheckAuth as any;
    checkAuth.mockResolvedValueOnce({ isAdmin: true });
    const users = [{ id: 1, userName: 'u', loginType: 0, loginInfo: 'e', country: 1, time: 0, balance: '0', shares: 0, trustPoint: 0, balanceToBuyShare: '0', distributePercent: 0, isAdmin: 1, adminPrivileges: 0 }];
    (D1QB as any).mockImplementationOnce(() => ({
      fetchAll: vi.fn().mockReturnThis(),
      fetchOne: vi.fn(),
      insert: vi.fn(),
      update: vi.fn(),
      execute: vi.fn().mockResolvedValue({ results: users }),
    }));
    const { resolve } = Admin.getAllUsers(mockFieldBuilder) as any;
    const res = await resolve({}, { jwtToken: 't' }, { env });
    expect(res).toEqual(users);
  });

  it('getAllUsers unauthorized', async () => {
    const { checkAuth } = CheckAuth as any;
    checkAuth.mockResolvedValueOnce({ isAdmin: false });
    const { resolve } = Admin.getAllUsers(mockFieldBuilder) as any;
    await expect(resolve({}, { jwtToken: 't' }, { env })).rejects.toThrow('UN_AUTHED');
  });

  it('createTask updates existing', async () => {
    const { checkAuth } = CheckAuth as any;
    checkAuth.mockResolvedValueOnce({ isAdmin: true });
    const update = vi.fn().mockReturnThis();
    const execute = vi.fn().mockResolvedValue({});
    (D1QB as any).mockImplementationOnce(() => ({
      fetchAll: vi.fn(),
      fetchOne: vi.fn(),
      insert: vi.fn(),
      update,
      execute,
    }));
    const { resolve } = Admin.createTask(mockFieldBuilder) as any;
    const res = await resolve({}, { taskId: 2, access: 0, jwtToken: 't', curriculumId: 1, shares: 1, parentId: 0, taskName: 't', taskType: 0, reDoIt: 0 }, { env });
    expect(res).toBe(true);
    expect(update).toHaveBeenCalled();
  });

  it('createTask inserts new', async () => {
    const { checkAuth } = CheckAuth as any;
    checkAuth.mockResolvedValueOnce({ isAdmin: true });
    const insert = vi.fn().mockReturnThis();
    const execute = vi.fn().mockResolvedValue({});
    (D1QB as any).mockImplementationOnce(() => ({
      fetchAll: vi.fn(),
      fetchOne: vi.fn(),
      insert,
      update: vi.fn(),
      execute,
    }));
    const { resolve } = Admin.createTask(mockFieldBuilder) as any;
    const res = await resolve({}, { access: 0, jwtToken: 't', curriculumId: 1, shares: 1, parentId: 0, taskName: 't', taskType: 0, reDoIt: 0 }, { env });
    expect(res).toBe(true);
    expect(insert).toHaveBeenCalled();
  });

  it('createTask unauthorized', async () => {
    const { checkAuth } = CheckAuth as any;
    checkAuth.mockResolvedValueOnce({ isAdmin: false });
    const { resolve } = Admin.createTask(mockFieldBuilder) as any;
    await expect(resolve({}, { access: 0, jwtToken: 't', curriculumId: 1, shares: 1, parentId: 0, taskName: 't', taskType: 0, reDoIt: 0 }, { env })).rejects.toThrow('UN_AUTHED');
  });

  it('getTasks returns list', async () => {
    const { checkAuth } = CheckAuth as any;
    checkAuth.mockResolvedValueOnce({ isAdmin: true });
    const tasks = [{ id: 1, time: 0, shares: 1, taskType: 0, taskName: 'n', curriculumId: 1, parentId: 0, status: 0, occupied: 0, occupiedTime: 0, reDoIt: 0, reDoItNum: 0, access: 0 }];
    (D1QB as any).mockImplementationOnce(() => ({
      fetchAll: vi.fn().mockReturnThis(),
      fetchOne: vi.fn(),
      insert: vi.fn(),
      update: vi.fn(),
      execute: vi.fn().mockResolvedValue({ results: tasks }),
    }));
    const { resolve } = Admin.getTasks(mockFieldBuilder) as any;
    const res = await resolve({}, { jwtToken: 't', curriculumId: 1 }, { env });
    expect(res).toEqual(tasks);
  });

  it('getTasks unauthorized', async () => {
    const { checkAuth } = CheckAuth as any;
    checkAuth.mockResolvedValueOnce({ isAdmin: false });
    const { resolve } = Admin.getTasks(mockFieldBuilder) as any;
    await expect(resolve({}, { jwtToken: 't', curriculumId: 1 }, { env })).rejects.toThrow('UN_AUTHED');
  });

  it('submitShares works', async () => {
    const { checkAuth } = CheckAuth as any;
    checkAuth.mockResolvedValueOnce({ isAdmin: true });
    const userFetch = { results: { trustPoint: 0, shares: 0 } };
    (D1QB as any).mockImplementation(() => ({
      fetchAll: vi.fn().mockReturnThis(),
      fetchOne: vi.fn().mockReturnThis(),
      insert: vi.fn().mockReturnThis(),
      update: vi.fn().mockReturnThis(),
      execute: vi.fn().mockResolvedValue(userFetch),
    }));
    const { resolve } = Admin.submitShares(mockFieldBuilder) as any;
    const data = JSON.stringify([{ id: 1, shares: 1, taskShare: 1 }]);
    const res = await resolve({}, { jwtToken: 't', curriculumId: 1, taskId: 1, data }, { env });
    expect(res).toBe(true);
  });

  it('submitShares unauthorized', async () => {
    const { checkAuth } = CheckAuth as any;
    checkAuth.mockResolvedValueOnce({ isAdmin: false });
    const { resolve } = Admin.submitShares(mockFieldBuilder) as any;
    await expect(resolve({}, { jwtToken: 't', curriculumId: 1, taskId: 1, data: '[]' }, { env })).rejects.toThrow('UN_AUTHED');
  });
});
