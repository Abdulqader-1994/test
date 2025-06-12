DROP TABLE IF EXISTS "shares";
CREATE TABLE IF NOT EXISTS "shares" (
  "id" INTEGER PRIMARY KEY AUTOINCREMENT,
  "createdAt" NUMERIC NOT NULL,
  "taskId" INTEGER NOT NULL, /* the userTask id */
	"amount" INTEGER NOT NULL, /* user share balance */
  "source" INTEGER NOT NULL, /* 1: mean work, 2: mean trade */
	"userId" INTEGER NOT NULL
);

DROP INDEX IF EXISTS sharesIndex;
CREATE INDEX IF NOT EXISTS sharesIndex ON shares (userId, createdAt);
