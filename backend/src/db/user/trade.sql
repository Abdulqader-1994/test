DROP TABLE IF EXISTS "trade";

CREATE TABLE IF NOT EXISTS "trade" (
  "id" INTEGER PRIMARY KEY AUTOINCREMENT,
  "createdAt" NUMERIC NOT NULL,
  "amount" INTEGER NOT NULL,
  "price" INTEGER NOT NULL,
  "orderType" INTEGER NOT NULL, /* 0 is buy | 1 is sell */
  "orderStatus" INTEGER NOT NULL, /* 0: canceled | 1: open | 2: done */
  "executed" INTEGER NOT NULL, /* how many share from the amount already done */
  "userId" INTEGER NOT NULL
);

DROP INDEX IF EXISTS tradeIndex;
CREATE INDEX IF NOT EXISTS tradeIndex ON trade (createdAt, price, orderStatus, userId);