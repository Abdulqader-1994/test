DROP TABLE IF EXISTS "snapshot";

/* snapshot added by system only so it's not in sync with shares real time */
CREATE TABLE IF NOT EXISTS "snapshot" (
  "id" INTEGER PRIMARY KEY AUTOINCREMENT,
  "createdAt" NUMERIC NOT NULL,
	"balance" INTEGER NOT NULL, /* user share balance */
	"userId" INTEGER
);

DROP INDEX IF EXISTS snapshotIndex;
CREATE INDEX IF NOT EXISTS snapshotIndex ON snapshot (userId, createdAt);