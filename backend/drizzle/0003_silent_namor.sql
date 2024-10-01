CREATE TABLE IF NOT EXISTS "liquidity" (
	"owner" text PRIMARY KEY NOT NULL,
	"offchain_id" text PRIMARY KEY NOT NULL,
	"locked" boolean,
	"amount" boolean
);
--> statement-breakpoint
ALTER TABLE "registration" ALTER COLUMN "revolut" SET DEFAULT ARRAY[]::text[];