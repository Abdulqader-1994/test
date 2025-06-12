DROP TABLE IF EXISTS "statistics";

CREATE TABLE IF NOT EXISTS "statistics" (
	"createdAt" NUMERIC NOT NULL,
	"price" INTEGER NOT NULL
);

DROP INDEX IF EXISTS statisticsIndex;
CREATE INDEX IF NOT EXISTS statisticsIndex ON statistics (createdAt);