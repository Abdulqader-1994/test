DROP TABLE IF EXISTS "profit";

/* every profit come to the platform */
CREATE TABLE IF NOT EXISTS "profit" (
  "id" INTEGER PRIMARY KEY AUTOINCREMENT,
  "createdAt" NUMERIC NOT NULL,
  "amount" Text NOT NULL,
  "currency" Text NOT NULL,
  "totalShare" INTEGER NOT NULL /* all platform share in the time of profit */
);

DROP INDEX IF EXISTS profitIndex;
CREATE INDEX IF NOT EXISTS profitIndex ON profit (createdAt);

