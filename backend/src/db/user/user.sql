DROP TABLE IF EXISTS "user";

CREATE TABLE IF NOT EXISTS "user" (
  "id" INTEGER PRIMARY KEY AUTOINCREMENT,
  "userName" TEXT,
	"password" TEXT,
	"verified" INTEGER NOT NULL, /* 0 is false | 1 is true */
	"lastEmailTime" NUMERIC,
	"sentCode" INTEGER,
  "time" NUMERIC NOT NULL, /* the time where the account created */
	"loginType" INTEGER NOT NULL, /* 0 is email | 1 is google | 2 is facebook  */
	"loginInfo" TEXT, /* email / googld id / facebook id */
	"country" INTEGER NOT NULL,
	"balanceToBuyShare" Text NOT NULL,
	"balance" TEXT NOT NULL, /* user money */
  "shares" INTEGER NOT NULL,
	"trustPoint" NUMERIC NOT NULL, /* the user trust point */
	"distributePercent" INTEGER NOT NULL,
	"isAdmin" INTEGER NOT NULL DEFAULT 0, /* 0: not admin | 1: admin */
	"adminPrivileges" INTEGER NOT NULL DEFAULT 0 /* the lower the better */
);

DROP INDEX IF EXISTS userIndex;
CREATE INDEX IF NOT EXISTS userIndex ON user (loginType, loginInfo);

/*
email:	system@ailence.ai
pass:		aiRoot.2017-2025@ailence.com

email:	marrawi@ailence.ai
pass:		Abd_Mar@Admin.1994$

email:	awwad@ailence.ai
pass:		Anas_Awwad_Admin@1990$Ma
*/

INSERT INTO "user" ("userName","password","verified","time","loginType","loginInfo","country","balanceToBuyShare", "balance", "shares", "trustPoint","distributePercent","isAdmin","adminPrivileges")VALUES ('system','cf88fc88e27118085f0fd04aeccb80d6:cd17e588fdf53636cf632e90a1befb9e40668a305c54583f187056ae6f3e7656',1, strftime('%s','now'), 0,  'system@ailence.ai', 963, '0.0', '3000000.00', 0, 60, 100, 1, 0);

INSERT INTO "user" ("userName","password","verified","time","loginType","loginInfo","country","balanceToBuyShare", "balance", "shares",  "trustPoint","distributePercent","isAdmin","adminPrivileges")VALUES ('marrawi','581bdf8ae66358fa79678e143739b591:28a08d462e3cefbe6521b914aba738a32c35d9a288981026bb753afcb498acab',1, strftime('%s','now'), 0,  'marrawi@ailence.ai', 963, '0.0', '1000.00', 0, 60, 50, 1, 1);

INSERT INTO "user" ("userName","password","verified","time","loginType","loginInfo","country","balanceToBuyShare", "balance", "shares",  "trustPoint","distributePercent","isAdmin","adminPrivileges")VALUES ('awwad','82e336072a6d7421d62591dae1b9c090:0db1c4a0f8b068d6c76a46272ba9ecc0df3c08b005c2c7d3d7efcbba798f3f2c',1, strftime('%s','now'), 0,  'awwad@ailence.ai', 963, '0.0', '1000.00', 0, 60, 50, 1, 2);