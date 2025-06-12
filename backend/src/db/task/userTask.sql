DROP TABLE IF EXISTS "userTask";
CREATE TABLE IF NOT EXISTS "userTask" (
	"id" INTEGER PRIMARY KEY AUTOINCREMENT,
  "time" NUMERIC NOT NULL,
	"doItNum" INTEGER NOT NULL, /* 0: mean submit | 1 or more: for verify */
	"status" INTEGER NOT NULL, /* -1: cancelled | 0: pending| 1: verfied */
	"userId" INTEGER NOT NULL,
	"taskId" INTEGER NOT NULL,
	"curriculumId" INTEGER NOT NULL,
	"userShare" INTEGER /* the share earned via user, may be less or same or more than the default share */
);

DROP INDEX IF EXISTS userTaskIndex;
CREATE INDEX IF NOT EXISTS userTaskIndex ON userTask (curriculumId, userId, taskId);