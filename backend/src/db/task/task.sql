DROP TABLE IF EXISTS "task";
CREATE TABLE IF NOT EXISTS "task" (
	"id" INTEGER PRIMARY KEY AUTOINCREMENT,
	"parentId" INTEGER NOT NULL, /* curriculum id or big Indexes id or small indexes id or task id */
	"time" NUMERIC NOT NULL,
	"shares" INTEGER NOT NULL, /* is is also the required time to do */
	"status" INTEGER NOT NULL,  /* 0: to do | 1: verify | 2: admin verify | 3: complete */
	"occupied" INTEGER NOT NULL, /* 0: mean no occupied, 1,2,3... : mean the id of user how occupie the task */
	"occupiedTime" INTEGER,
	"reDoIt" INTEGER NOT NULL, /* how many time to verify the task */
	"reDoItNum" INTEGER NOT NULL, /* the number this task verfied */
	"access" INTEGER NOT NULL, /* 0: for all users, 1,2,3,4,... : for admin with previlges (minus one) ,  */
	"taskName" TEXT NOT NULL,
	"taskType" INTEGER NOT NULL,
	"curriculumId" INTEGER NOT NULL
);

DROP INDEX IF EXISTS taskIndex;
CREATE INDEX IF NOT EXISTS taskIndex ON task (status, occupied, curriculumId);

/*
  taskType consist of:
  0 = adding big indexes										(1 verify persons) (admins only)
  1 = adding files													(1 verify persons) (admins only)
  2 = add small indexes											(3 verify persons)
  3 = adding raw data to small indexes			(5 verify persons)
  4 = arrangement and style adding data			(3 verify persons)
  6 = shorten data if possible				(3 verify persons)
  8 = review the entire lesson							(1 verify persons) (admins only)
*/