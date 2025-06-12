DROP TABLE IF EXISTS "curriculum";

CREATE TABLE IF NOT EXISTS "curriculum" (
	"id" INTEGER PRIMARY KEY AUTOINCREMENT,
	"name" TEXT NOT NULL,
	"countryId" INTEGER NOT NULL,
	"levelType" INTEGER NOT NULL, /* 0: is school | 1: is university */
	"level" Text NOT NULL,
	"semester" INTEGER NOT NULL, /* 0: for whole year | 1: semester one | 2: is semester two */
	"completedPercent" INTEGER NOT NULL DEFAULT 0,
	"openToWork" INTEGER NOT NULL
);
