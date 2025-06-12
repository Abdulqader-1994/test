DROP TABLE IF EXISTS "subscribed";

CREATE TABLE IF NOT EXISTS "subscribed" (
  "id" INTEGER PRIMARY KEY AUTOINCREMENT,
  "createdAt" NUMERIC NOT NULL,
  "userId" INTEGER NOT NULL,
	"curriculumId" INTEGER NOT NULL,
  "purchased" INTEGER NOT NULL /* 0: unPaid (becuase the first chapter is free) | 1: paid */
);

DROP INDEX IF EXISTS subscribedIndex;
CREATE INDEX IF NOT EXISTS subscribedIndex ON subscribed (userId);