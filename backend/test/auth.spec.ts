import { describe, it, expect, beforeEach, vi } from 'vitest';
import Auth from '../src/libs/auth';
import AppError from '../src/utils/error';

vi.mock('../src/utils/check_auth', () => ({ checkAuth: vi.fn() })); // not used but for completeness if imported

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

const mailMock = {
  ops: [] as any[],
  results: [] as any[],
  reset() {
    this.ops = [];
    this.results = [];
  },
};

const fetchMock = {
  ops: [] as any[],
  results: [] as any[],
  reset() {
    this.ops = [];
    this.results = [];
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

vi.mock('mailtrap', () => ({
  MailtrapClient: class {
    token: string;
    constructor(opts: any) { this.token = opts.token; }
    async send(data: any) {
      mailMock.ops.push({ token: this.token, data });
      return mailMock.results.shift() ?? { success: true };
    }
  }
}));

const t: any = { arg: { string: () => ({}), int: () => ({}) }, field: (opts: any) => opts };
const ctx: any = { env: { USER_DB: 'user', JWT_SECRET: 'secret', MAILTRAP_TOKEN: 'm', GOOGLE_CLIENT_ID_DESKTOP: 'id', GOOGLE_CLIENT_SECRET_DESKTOP: 'sec', GOOGLE_CLIENT_ID_WEB: 'idw', GOOGLE_CLIENT_SECRET_WEB: 'secw' } };

beforeEach(() => {
  qbMock.reset();
  mailMock.reset();
  fetchMock.reset();
  (globalThis.fetch as any) = vi.fn((...args: any[]) => {
    fetchMock.ops.push(args);
    const res = fetchMock.results.shift() ?? { json: async () => ({}) };
    return Promise.resolve(res);
  });
  vi.useRealTimers();
});

// helper to hash password like the implementation
async function hashPassword(password: string) {
  const salt = crypto.getRandomValues(new Uint8Array(16));
  const enc = new TextEncoder();
  const keyMaterial = await crypto.subtle.importKey('raw', enc.encode(password), { name: 'PBKDF2' }, false, ['deriveBits', 'deriveKey']);
  const key = await crypto.subtle.deriveKey({ name: 'PBKDF2', salt, iterations: 100000, hash: 'SHA-256' }, keyMaterial, { name: 'AES-GCM', length: 256 }, true, ['encrypt', 'decrypt']);
  const hashBuffer = await crypto.subtle.exportKey('raw', key);
  const hashHex = Array.from(new Uint8Array(hashBuffer)).map(b => b.toString(16).padStart(2, '0')).join('');
  const saltHex = Array.from(salt).map(b => b.toString(16).padStart(2, '0')).join('');
  return `${saltHex}:${hashHex}`;
}

// createEmailAccount
describe('Auth.createEmailAccount', () => {
  it('throws when email exists', async () => {
    qbMock.fetchOneResults.push({ results: {} });
    const field = Auth.createEmailAccount(t) as any;
    await expect(field.resolve(null, { email: 'a', password: 'p' }, ctx)).rejects.toThrow(AppError.DATA_EXIST);
  });

  it('throws on insert failure', async () => {
    qbMock.fetchOneResults.push({ results: null });
    qbMock.insertResults.push({ results: null });
    const field = Auth.createEmailAccount(t) as any;
    await expect(field.resolve(null, { email: 'a', password: 'p' }, ctx)).rejects.toThrow(AppError.UNKNOW_ERROR);
  });

  it('returns id when created', async () => {
    qbMock.fetchOneResults.push({ results: null });
    qbMock.insertResults.push({ results: { id: 5 } });
    const field = Auth.createEmailAccount(t) as any;
    const res = await field.resolve(null, { email: 'a', password: 'p' }, ctx);
    expect(res).toBe(5);
    expect(qbMock.ops.find(o => o.method === 'insert')).toBeTruthy();
  });
});

// sendVerificationEmail
describe('Auth.sendVerificationEmail', () => {
  it('throws when user missing', async () => {
    qbMock.fetchOneResults.push({ results: null });
    const field = Auth.sendVerificationEmail(t) as any;
    await expect(field.resolve(null, { email: 'e' }, ctx)).rejects.toThrow(AppError.UNKNOW_ERROR);
  });

  it('throws when too many emails', async () => {
    vi.useFakeTimers();
    vi.setSystemTime(0);
    qbMock.fetchOneResults.push({ results: { id: 1, loginInfo: 'e', lastEmailTime: 1 } });
    const field = Auth.sendVerificationEmail(t) as any;
    await expect(field.resolve(null, { email: 'e' }, ctx)).rejects.toThrow(AppError.TOO_MANY_EMAIL);
    vi.useRealTimers();
  });

  it('sends mail and updates', async () => {
    qbMock.fetchOneResults.push({ results: { id: 2, loginInfo: 'e', lastEmailTime: null } });
    mailMock.results.push({ success: true });
    qbMock.updateResults.push({ success: true });
    const field = Auth.sendVerificationEmail(t) as any;
    const res = await field.resolve(null, { email: 'e' }, ctx);
    expect(res).toBe(true);
    expect(mailMock.ops.length).toBe(1);
    expect(qbMock.ops.find(o => o.method === 'update')).toBeTruthy();
  });
});

// socialLogin
describe('Auth.socialLogin', () => {
  it('throws for invalid token', async () => {
    fetchMock.results.push({ json: async () => ({ access_token: 't' }) });
    fetchMock.results.push({ json: async () => ({ id: '' }) });
    qbMock.fetchOneResults.push({ results: null });
    const field = Auth.socialLogin(t) as any;
    await expect(field.resolve(null, { redirectUri: '', loginType: 'google', platform: 'desktop', code: 'c', alreadyHasId: '' }, ctx)).rejects.toThrow(AppError.INVALID_TOKEN);
  });

  it('signs in existing user', async () => {
    qbMock.fetchOneResults.push({ results: { id: 1, password: 'h', verified: 1, userName: 'u', lastEmailTime: 0, sentCode: 0, loginType: 0, loginInfo: 'i', country: 1, time: 0, trustPoint: 0, balance: '0', shares: 0, balanceToBuyShare: '0', distributePercent: 0, isAdmin: 0, adminPrivileges: 0 } });
    const field = Auth.socialLogin(t) as any;
    const res = await field.resolve(null, { redirectUri: '', loginType: 'google', platform: 'desktop', code: '', alreadyHasId: 'i' }, ctx);
    expect(res.id).toBe(1);
    expect(res.jwtToken).toBeTruthy();
    expect(qbMock.ops.find(o => o.method === 'fetchOne')).toBeTruthy();
  });

  it('creates new user', async () => {
    qbMock.fetchOneResults.push({ results: null });
    qbMock.insertResults.push({ results: { id: 3 } });
    const field = Auth.socialLogin(t) as any;
    const res = await field.resolve(null, { redirectUri: '', loginType: 'google', platform: 'desktop', code: '', alreadyHasId: 'nid' }, ctx);
    expect(res.id).toBe(3);
    expect(qbMock.ops.find(o => o.method === 'insert')).toBeTruthy();
  });

  it('throws when insert fails', async () => {
    qbMock.fetchOneResults.push({ results: null });
    qbMock.insertResults.push({ results: null });
    const field = Auth.socialLogin(t) as any;
    await expect(field.resolve(null, { redirectUri: '', loginType: 'google', platform: 'desktop', code: '', alreadyHasId: 'nid' }, ctx)).rejects.toThrow(AppError.UNKNOW_ERROR);
  });
});

// emailLogin
describe('Auth.emailLogin', () => {
  it('throws when email not found', async () => {
    qbMock.fetchOneResults.push({ results: null });
    const field = Auth.emailLogin(t) as any;
    await expect(field.resolve(null, { email: 'e', password: 'p' }, ctx)).rejects.toThrow(AppError.WRONG_DATA);
  });

  it('throws when unverified', async () => {
    qbMock.fetchOneResults.push({ results: { verified: 0 } });
    const field = Auth.emailLogin(t) as any;
    await expect(field.resolve(null, { email: 'e', password: 'p' }, ctx)).rejects.toThrow(AppError.UNVERIFIED_EMAIL);
  });

  it('throws when password wrong', async () => {
    const stored = await hashPassword('right');
    qbMock.fetchOneResults.push({ results: { verified: 1, password: stored } });
    const field = Auth.emailLogin(t) as any;
    await expect(field.resolve(null, { email: 'e', password: 'wrong' }, ctx)).rejects.toThrow(AppError.WRONG_DATA);
  });

  it('returns account on success', async () => {
    const stored = await hashPassword('pass');
    qbMock.fetchOneResults.push({ results: { id: 4, verified: 1, password: stored, userName: 'u', lastEmailTime: 0, sentCode: 0, loginType: 0, loginInfo: 'e', country: 1, time: 0, trustPoint: 0, balance: '0', shares: 0, balanceToBuyShare: '0', distributePercent: 0, isAdmin: 0, adminPrivileges: 0 } });
    const field = Auth.emailLogin(t) as any;
    const res = await field.resolve(null, { email: 'e', password: 'pass' }, ctx);
    expect(res.id).toBe(4);
    expect(res.jwtToken).toBeTruthy();
  });
});

// verifyEmail
describe('Auth.verifyEmail', () => {
  it('throws when user missing', async () => {
    qbMock.fetchOneResults.push({ results: null });
    const field = Auth.verifyEmail(t) as any;
    await expect(field.resolve(null, { email: 'e', code: 1 }, ctx)).rejects.toThrow(AppError.UNKNOW_ERROR);
  });

  it('throws for wrong code', async () => {
    qbMock.fetchOneResults.push({ results: { lastEmailTime: 0, sentCode: 2 } });
    const field = Auth.verifyEmail(t) as any;
    await expect(field.resolve(null, { email: 'e', code: 1 }, ctx)).rejects.toThrow(AppError.CODE_INVALID);
  });

  it('verifies and updates', async () => {
    vi.useFakeTimers();
    vi.setSystemTime(0);
    qbMock.fetchOneResults.push({ results: { lastEmailTime: 0, sentCode: 1 } });
    qbMock.updateResults.push({ success: true });
    const field = Auth.verifyEmail(t) as any;
    const res = await field.resolve(null, { email: 'e', code: 1 }, ctx);
    expect(res).toBe(true);
    expect(qbMock.ops.find(o => o.method === 'update')).toBeTruthy();
    vi.useRealTimers();
  });
});

// restorePassword
describe('Auth.restorePassword', () => {
  it('throws when user missing', async () => {
    qbMock.fetchOneResults.push({ results: null });
    const field = Auth.restorePassword(t) as any;
    await expect(field.resolve(null, { email: 'e' }, ctx)).rejects.toThrow(AppError.WRONG_DATA);
  });

  it('throws when too many emails', async () => {
    vi.useFakeTimers();
    vi.setSystemTime(0);
    qbMock.fetchOneResults.push({ results: { id: 1, loginInfo: 'e', lastEmailTime: 1 } });
    const field = Auth.restorePassword(t) as any;
    await expect(field.resolve(null, { email: 'e' }, ctx)).rejects.toThrow(AppError.TOO_MANY_EMAIL);
    vi.useRealTimers();
  });

  it('throws when id missing', async () => {
    qbMock.fetchOneResults.push({ results: { id: null } });
    const field = Auth.restorePassword(t) as any;
    await expect(field.resolve(null, { email: 'e' }, ctx)).rejects.toThrow(AppError.UNKNOW_ERROR);
  });

  it('sends email and updates', async () => {
    qbMock.fetchOneResults.push({ results: { id: 2, loginInfo: 'e', lastEmailTime: null } });
    mailMock.results.push({ success: true });
    qbMock.updateResults.push({ success: true });
    const field = Auth.restorePassword(t) as any;
    const res = await field.resolve(null, { email: 'e' }, ctx);
    expect(res).toBe(2);
    expect(mailMock.ops.length).toBe(1);
    expect(qbMock.ops.find(o => o.method === 'update')).toBeTruthy();
  });
});

// verifyPasswordCode
describe('Auth.verifyPasswordCode', () => {
  it('throws when user missing', async () => {
    qbMock.fetchOneResults.push({ results: null });
    const field = Auth.verifyPasswordCode(t) as any;
    await expect(field.resolve(null, { code: 1, email: 'e', password: 'p' }, ctx)).rejects.toThrow(AppError.UNKNOW_ERROR);
  });

  it('throws for wrong code', async () => {
    qbMock.fetchOneResults.push({ results: { lastEmailTime: 0, sentCode: 2 } });
    const field = Auth.verifyPasswordCode(t) as any;
    await expect(field.resolve(null, { code: 1, email: 'e', password: 'p' }, ctx)).rejects.toThrow(AppError.CODE_INVALID);
  });

  it('updates password', async () => {
    vi.useFakeTimers();
    vi.setSystemTime(0);
    qbMock.fetchOneResults.push({ results: { lastEmailTime: 0, sentCode: 1 } });
    qbMock.updateResults.push({ success: true });
    const field = Auth.verifyPasswordCode(t) as any;
    const res = await field.resolve(null, { code: 1, email: 'e', password: 'p' }, ctx);
    expect(res).toBe(true);
    expect(qbMock.ops.find(o => o.method === 'update')).toBeTruthy();
    vi.useRealTimers();
  });
});
