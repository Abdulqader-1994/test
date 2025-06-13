import { D1QB } from "workers-qb";
import { MailtrapClient } from "mailtrap";
import AppError from "../utils/error";
import { GraphQLError } from "graphql";
import { Account, mutateBuilderType, queryBuilderType } from "../graphql/types";
import jwt from "@tsndr/cloudflare-worker-jwt";
import { accountRef } from "../graphql/refs";
import { BackeEndEnv } from "../graphql/builder";

export default class Auth {
  static createEmailAccount = (t: mutateBuilderType) => t.field({
    type: "Int",
    args: {
      email: t.arg.string({ required: true }),
      password: t.arg.string({ required: true }),
    },
    resolve: async (_parent, args, ctx) => {
      const database = new D1QB(ctx.env.USER_DB);

      // check if user exist
      let res = await database
        .fetchOne({
          tableName: "user",
          where: { conditions: ["loginInfo = ?1"], params: [args.email] },
        })
        .execute();

      if (res.results) throw new GraphQLError(AppError.DATA_EXIST);

      const password = await hashPassword(args.password);

      res = await database
        .insert({
          tableName: "user",
          data: {
            password: password,
            userName: null,
            verified: 0,
            time: Date.now(),
            loginType: 0,
            loginInfo: args.email,
            country: 20,
            trustPoint: 60,
            balance: '1000.00',
            shares: 0,
            balanceToBuyShare: "0.0",
            distributePercent: 5,
          },
          returning: "id",
        })
        .execute();

      const id = res.results?.id;
      if (id == null) throw new GraphQLError(AppError.UNKNOW_ERROR);

      return id as number;
    },
  });

  static sendVerificationEmail = (t: queryBuilderType) => t.field({
    type: "Boolean",
    args: { email: t.arg.string({ required: true }) },
    resolve: async (_parent, args, ctx) => {
      const database = new D1QB(ctx.env.USER_DB);
      const user = await database
        .fetchOne({ tableName: "user", where: { conditions: ["loginInfo = ?1"], params: [args.email] } })
        .execute();

      if (!user.results) throw new GraphQLError(AppError.UNKNOW_ERROR);

      if (user.results!.lastEmailTime) {
        const lastEmailTime = (user.results!.lastEmailTime as number) + 2 * 60 * 1000;
        if (Date.now() < lastEmailTime) throw new GraphQLError(AppError.TOO_MANY_EMAIL);
      }

      const client = new MailtrapClient({ token: ctx.env.MAILTRAP_TOKEN });

      const code = Math.floor(100000 + Math.random() * 900000);

      const emailContent = `
        <!DOCTYPE html>
        <html lang="ar" dir="rtl">
          <head>
            <meta charset="UTF-8" />
            <meta name="viewport" content="width=device-width, initial-scale=1.0" />
            <title>تأكيد البريد الإلكتروني - Ailence</title>
          </head>
          <body style="font-family: 'El Messiri', sans-serif; background-color: #f4f4f4; margin: 0; padding: 0;">
            <!-- Inline font-face definition in the body -->
            <style type="text/css">
              @import url('https://fonts.googleapis.com/css2?family=El+Messiri:wght@400..700&display=swap');
            </style>
  
            <div style="width: 100%; max-width: 600px; margin: 30px auto; background-color: #ffffff; border-radius: 8px; box-shadow: 0 0 10px rgba(0,0,0,0.1); overflow: hidden;">
              <div style="background-color: blue; color: #ffffff; padding: 20px; text-align: center;">
                <h1 style="margin: 0;">مرحباً بكم في AILENCE</h1>
              </div>
              <div style="padding: 30px; color: #333333; line-height: 1.6; text-align: center;">
                <p style="margin: 0 0 20px;">:شكرًا لتسجيلك معنا. يرجى استخدام رمز التحقق أدناه لتأكيد بريدك الإلكتروني</p>
                <div style="display: block; margin: 20px auto; padding: 10px 20px; background-color: #eeeeee; font-size: 24px; font-weight: bold; text-align: center; letter-spacing: 4px; border-radius: 4px; width: fit-content;">
                  ${code}
                </div>
                 <p style="margin: 20px 0;">هذا الكود مدته 15 دقيقة فقط، ولن يكون صالحاً أكثر من هذه المدة</p>
                 <hr style="border: none; border-top: 1px solid #ddd; margin: 20px 0;" />
                <p style="margin: 20px 0;">إذا لم تقم بطلب إنشاء حساب، يرجى تجاهل هذا البريد الإلكتروني.</p>
                <hr style="border: none; border-top: 1px solid #ddd; margin: 20px 0;" />
                <p style="margin: 0;">مع تحيات فريق Ailence</p>
              </div>
              <div style="text-align: center; padding: 15px; font-size: 12px; color: #777777; background-color: #f9f9f9;">
                <p style="margin: 0;">جميع الحقوق محفوظة. Ailence © 2025.</p>
              </div>
            </div>
          </body>
        </html>
      `;

      try {
        const res = await client.send({
          from: { name: "Ailence", email: "support@ailence.com" },
          to: [{ email: user.results.loginInfo as string, name: "Ailence" }],
          subject: `Ailence Verification Code: ${code}`,
          html: emailContent,
        });

        if (res.success) {
          const database = new D1QB(ctx.env.USER_DB);
          await database
            .update({
              tableName: "user",
              data: { lastEmailTime: Date.now(), sentCode: code },
              where: { conditions: "id = ?1", params: user.results.id },
            })
            .execute();
        }
      } catch (error) {
        console.log(error);
      }

      return true;
    },
  });

  static socialLogin = (t: queryBuilderType) => t.field({
    type: accountRef,
    args: {
      redirectUri: t.arg.string({ required: true }),
      loginType: t.arg.string({ required: true }),
      platform: t.arg.string({ required: true }),
      code: t.arg.string({ required: true }),
      alreadyHasId: t.arg.string({ required: true }),
    },
    resolve: async (_parent, args, ctx) => {
      // get login info
      let info: string = "";
      let type: number = 0;

      if (args.loginType == "google") {
        type = 0;
        if (args.alreadyHasId.length > 0) {
          info = args.alreadyHasId;
        } else {
          info = await getGoogleToken(args.code, args.redirectUri, args.platform, ctx.env);
        }
      }

      if (!info) throw new GraphQLError(AppError.INVALID_TOKEN);

      const database = new D1QB(ctx.env.USER_DB);

      let res = await database.fetchOne({ tableName: "user", where: { conditions: ["loginType = ?1", "loginInfo = ?2"], params: [type, info] } }).execute();

      let user: Account;

      // user exist => sign in
      if (res.results) {
        user = {
          id: res.results.id as number,
          password: res.results.password as string,
          verified: res.results.verified as number,
          userName: res.results.userName as string,
          lastEmailTime: res.results.lastEmailTime as number,
          sentCode: res.results.sentCode as number,
          loginType: res.results.loginType as number,
          loginInfo: res.results.loginInfo as string,
          country: res.results.country as number,
          time: res.results.time as number,
          trustPoint: res.results.trustPoint as number,
          balance: res.results.balance as string,
          shares: res.results.shares as number,
          balanceToBuyShare: res.results.balanceToBuyShare as string,
          distributePercent: res.results.distributePercent as number,
          isAdmin: res.results.isAdmin as number,
          adminPrivileges: res.results.adminPrivileges as number,
          jwtToken: null,
        };
      }

      // user not exist => sign up
      else {
        user = {
          id: -1,
          password: null,
          verified: 1,
          lastEmailTime: Date.now(),
          sentCode: null,
          userName: null,
          loginType: type,
          loginInfo: info,
          time: Date.now(),
          country: 20,
          trustPoint: 60,
          balance: '1000.00',
          shares: 0,
          balanceToBuyShare: "0.0",
          distributePercent: 5,
          isAdmin: 0,
          adminPrivileges: 0,
          jwtToken: null,
        };

        res = await database
          .insert({
            tableName: "user",
            data: {
              userName: user.userName,
              time: Date.now(),
              loginType: user.loginType,
              loginInfo: user.loginInfo,
              country: user.country,
              trustPoint: user.trustPoint,
              balance: user.balance,
              shares: user.shares,
              balanceToBuyShare: user.balanceToBuyShare,
              distributePercent: user.distributePercent,
              isAdmin: user.isAdmin,
              adminPrivileges: user.adminPrivileges,
            },
            returning: "id",
          })
          .execute();

        if (res.results == null) throw new GraphQLError(AppError.UNKNOW_ERROR);
        user.id = res.results!.id as number;
      }

      user.jwtToken = await jwt.sign({ id: user.id, isAdmin: user.isAdmin }, ctx.env.JWT_SECRET);
      return user;
    },
  });

  static emailLogin = (t: queryBuilderType) => t.field({
    type: accountRef,
    args: {
      email: t.arg.string({ required: true }),
      password: t.arg.string({ required: true }),
    },
    resolve: async (_parent, args, ctx) => {
      const database = new D1QB(ctx.env.USER_DB);

      let res = await database.fetchOne({ tableName: "user", where: { conditions: ["loginInfo = ?1"], params: [args.email] } }).execute();

      if (res.results == null) throw new GraphQLError(AppError.WRONG_DATA);

      if (res.results.verified == 0) throw new GraphQLError(AppError.UNVERIFIED_EMAIL);

      const passwordEqual = await verifyPassword(res.results.password as string, args.password);
      if (!passwordEqual) throw new GraphQLError(AppError.WRONG_DATA);

      const user: Account = {
        id: res.results.id as number,
        password: null,
        verified: res.results.verified as number,
        lastEmailTime: res.results.lastEmailTime as number,
        sentCode: res.results.lastEmailTime as number,
        userName: res.results.userName as string,
        loginType: res.results.loginType as number,
        loginInfo: res.results.loginInfo as string,
        country: res.results.country as number,
        time: res.results.time as number,
        trustPoint: res.results.trustPoint as number,
        balance: res.results.balance as string,
        shares: res.results.shares as number,
        balanceToBuyShare: res.results.balanceToBuyShare as string,
        distributePercent: res.results.distributePercent as number,
        isAdmin: res.results.isAdmin as number,
        adminPrivileges: res.results.adminPrivileges as number,
        jwtToken: await jwt.sign({ id: res.results.id, isAdmin: res.results.isAdmin }, ctx.env.JWT_SECRET),
      };
      
      return user;
    },
  });

  static verifyEmail = (t: mutateBuilderType) => t.field({
    type: 'Boolean',
    args: {
      email: t.arg.string({ required: true }),
      code: t.arg.int({ required: true }),
    },
    resolve: async (_parent, args, ctx) => {
      const db = new D1QB(ctx.env.USER_DB);
      const res = await db.fetchOne({ tableName: "user", where: { conditions: "loginInfo = ?1", params: [args.email] } }).execute();

      if (res.results == null) throw new GraphQLError(AppError.UNKNOW_ERROR);

      const lastEmailTime = (res.results!.lastEmailTime as number) + 15 * 60 * 1000;

      // if code is not equal or email time excede 15 minture then the code is invalid
      if (args.code != res.results?.sentCode || Date.now() > lastEmailTime) throw new GraphQLError(AppError.CODE_INVALID);

      await db.update({ tableName: "user", data: { sentCode: null, verified: 1 }, where: { conditions: "loginInfo = ?1", params: [args.email] } }).execute();

      return true;
    }
  });

  static restorePassword = (t: queryBuilderType) => t.field({
    type: 'Int',
    args: { email: t.arg.string({ required: true }) },
    resolve: async (_parent, args, ctx) => {
      const database = new D1QB(ctx.env.USER_DB);
      const res = await database.fetchOne({ tableName: "user", where: { conditions: "loginInfo = ?1", params: [args.email] } }).execute();

      if (res.results == null) throw new GraphQLError(AppError.WRONG_DATA);

      if (res.results!.lastEmailTime) {
        const lastEmailTime = (res.results!.lastEmailTime as number) + 2 * 60 * 1000;
        if (Date.now() < lastEmailTime) throw new GraphQLError(AppError.TOO_MANY_EMAIL);
      }

      const client = new MailtrapClient({ token: ctx.env.MAILTRAP_TOKEN });

      const code = Math.floor(100000 + Math.random() * 900000);

      const emailContent = `
        <!DOCTYPE html>
        <html lang="ar" dir="rtl">
          <head>
            <meta charset="UTF-8" />
            <meta name="viewport" content="width=device-width, initial-scale=1.0" />
            <title>استعادة كلمة المرور - Ailence</title>
          </head>
          <body style="font-family: 'El Messiri', sans-serif; background-color: #f4f4f4; margin: 0; padding: 0;">
            <!-- Inline font-face definition in the body -->
            <style type="text/css">
              @import url('https://fonts.googleapis.com/css2?family=El+Messiri:wght@400..700&display=swap');
            </style>
  
            <div style="width: 100%; max-width: 600px; margin: 30px auto; background-color: #ffffff; border-radius: 8px; box-shadow: 0 0 10px rgba(0,0,0,0.1); overflow: hidden;">
              <div style="background-color: blue; color: #ffffff; padding: 20px; text-align: center;">
                <h1 style="margin: 0;">استعادة كلمة المرور</h1>
              </div>
              <div style="padding: 30px; color: #333333; line-height: 1.6; text-align: center;">
                <p style="margin: 0 0 20px;">
                  لقد طلبت استعادة كلمة المرور الخاصة بك. يرجى استخدام الكود أدناه لإعادة تعيين كلمة المرور الخاصة بك.
                </p>
                <div style="display: block; margin: 20px auto; padding: 10px 20px; background-color: #eeeeee; font-size: 24px; font-weight: bold; text-align: center; letter-spacing: 4px; border-radius: 4px; width: fit-content;">
                  ${code}
                </div>
                <p style="margin: 20px 0;">
                  هذا الكود مدته 15 دقيقة فقط، ولن يكون صالحاً بعد هذه الفترة.
                </p>
                <hr style="border: none; border-top: 1px solid #ddd; margin: 20px 0;" />
                <p style="margin: 20px 0;">
                  إذا لم تقم بطلب استعادة كلمة المرور، يرجى تجاهل هذا البريد الإلكتروني.
                </p>
                <hr style="border: none; border-top: 1px solid #ddd; margin: 20px 0;" />
                <p style="margin: 0;">
                  مع تحيات فريق Ailence
                </p>
              </div>
              <div style="text-align: center; padding: 15px; font-size: 12px; color: #777777; background-color: #f9f9f9;">
                <p style="margin: 0;">
                  جميع الحقوق محفوظة. Ailence © 2025.
                </p>
              </div>
            </div>
          </body>
        </html>
      `;

      const id = res.results?.id;
      if (id == null) throw new GraphQLError(AppError.UNKNOW_ERROR);

      try {
        const res = await client.send({
          from: { name: "Ailence", email: "support@ailence.com" },
          to: [{ email: args.email, name: "Ailence" }],
          subject: `Ailence Restore Code: ${code}`,
          html: emailContent,
        });

        if (res.success) {
          const database = new D1QB(ctx.env.USER_DB);
          await database.update({
            tableName: "user",
            data: { lastEmailTime: Date.now(), sentCode: code },
            where: { conditions: "id = ?1", params: [id] },
          }).execute();
        }
      } catch (error) {
        console.log(error);
      }

      return id as number;
    },
  });

  static verifyPasswordCode = (t: mutateBuilderType) => t.field({
    type: 'Boolean',
    args: {
      code: t.arg.int({ required: true }),
      email: t.arg.string({ required: true }),
      password: t.arg.string({ required: true }),
    },
    resolve: async (_parent, args, ctx) => {
      const database = new D1QB(ctx.env.USER_DB);
      const res = await database
        .fetchOne({
          tableName: "user",
          where: { conditions: "loginInfo = ?1", params: [args.email] },
        })
        .execute();

      if (res.results == null) throw new GraphQLError(AppError.UNKNOW_ERROR);

      const lastEmailTime = (res.results!.lastEmailTime as number) + 15 * 60 * 1000;

      // if code is not equal or email time excede 15 minture then the code is invalid
      if (args.code != res.results?.sentCode || Date.now() > lastEmailTime) {
        throw new GraphQLError(AppError.CODE_INVALID);
      }

      const password = await hashPassword(args.password);

      await database
        .update({
          tableName: "user",
          data: { sentCode: null, password: password },
          where: { conditions: "loginInfo = ?1", params: [args.email] },
        })
        .execute();

      return true;
    },
  });
}

async function hashPassword(password: string) {
  const salt = crypto.getRandomValues(new Uint8Array(16));
  const enc = new TextEncoder();

  const keyMaterial = await crypto.subtle.importKey("raw", enc.encode(password), { name: "PBKDF2" }, false, ["deriveBits", "deriveKey"]);

  const iterations = 100000;
  const key = await crypto.subtle.deriveKey(
    {
      name: "PBKDF2",
      salt: salt,
      iterations: iterations,
      hash: "SHA-256",
    },
    keyMaterial,
    { name: "AES-GCM", length: 256 },
    true,
    ["encrypt", "decrypt"]
  );

  const hashBuffer = await crypto.subtle.exportKey("raw", key);
  const hashUint8 = new Uint8Array(hashBuffer);
  const hashHex = bufferToHex(hashUint8);
  const saltHex = bufferToHex(salt);

  return `${saltHex}:${hashHex}`;
}

async function verifyPassword(storedPassword: string, providedPassword: string): Promise<boolean> {
  const [saltHex, hashHex] = storedPassword.split(":");

  const salt = hexToBuffer(saltHex);
  const enc = new TextEncoder();

  const keyMaterial = await crypto.subtle.importKey(
    "raw",
    enc.encode(providedPassword),
    { name: "PBKDF2" },
    false,
    ["deriveBits", "deriveKey"]
  );

  const iterations = 100000;

  const key = await crypto.subtle.deriveKey(
    { name: "PBKDF2", salt: salt, iterations: iterations, hash: "SHA-256" },
    keyMaterial,
    { name: "AES-GCM", length: 256 },
    true,
    ["encrypt", "decrypt"]
  );

  const derivedBuffer = await crypto.subtle.exportKey("raw", key);
  const derivedHashHex = bufferToHex(new Uint8Array(derivedBuffer));

  return derivedHashHex === hashHex;
}

function hexToBuffer(hex: string): Uint8Array {
  const bytes = new Uint8Array(hex.length / 2);
  for (let i = 0; i < hex.length; i += 2) {
    bytes[i / 2] = parseInt(hex.substr(i, 2), 16);
  }
  return bytes;
}

function bufferToHex(buffer: Uint8Array): string {
  return Array.from(buffer)
    .map((byte) => byte.toString(16).padStart(2, "0"))
    .join("");
}

async function getGoogleToken(code: string, redirectUri: string, platform: String, env: BackeEndEnv) {
  let client_id: String;
  let client_secret: String;
  if (platform == "desktop") {
    client_id = env.GOOGLE_CLIENT_ID_DESKTOP;
    client_secret = env.GOOGLE_CLIENT_SECRET_DESKTOP;
  } else {
    client_id = env.GOOGLE_CLIENT_ID_WEB;
    client_secret = env.GOOGLE_CLIENT_SECRET_WEB;
  }

  const url = await fetch("https://oauth2.googleapis.com/token", {
    headers: { "content-type": "application/json", accept: "application/json" },
    method: "POST",
    body: JSON.stringify({
      code: code,
      client_id: client_id,
      client_secret: client_secret,
      redirect_uri: redirectUri,
      grant_type: "authorization_code",
    }),
  });

  const access: any = await url.json();
  const token = access.access_token;

  let data = await fetch("https://www.googleapis.com/oauth2/v2/userinfo", {
    headers: { authorization: `Bearer ${token}` },
  });
  let res: any = await data.json();

  return res.id;
}
