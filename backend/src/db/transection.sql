DROP TABLE IF EXISTS "transection";

CREATE TABLE IF NOT EXISTS "transection" (
  "id" INTEGER PRIMARY KEY AUTOINCREMENT,
  "userId" INTEGER NOT NULL,
	"time" INTEGER NOT NULL,
	"amount" Text NOT NULL,
	"currencyInfo" Text,
  "provider" TEXT NOT NULL,
	"type" INTEGER NOT NULL /* 0 is withdraw | 1 is deposit  */
);

DROP INDEX IF EXISTS transectionIndex;
CREATE INDEX IF NOT EXISTS transectionIndex ON transection (userId);