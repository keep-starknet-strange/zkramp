CREATE TABLE IF NOT EXISTS "registration" (
	"address" text PRIMARY KEY NOT NULL,
	"revolut" text[] DEFAULT '{}'::text[] NOT NULL
);
--> statement-breakpoint
DROP TABLE "indexer_locked";--> statement-breakpoint
DROP TABLE "indexer_unlocked";