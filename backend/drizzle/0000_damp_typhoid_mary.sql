DO $$ BEGIN
 CREATE TYPE "public"."network_type" AS ENUM('mainnet', 'sepolia');
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;
--> statement-breakpoint
CREATE TABLE IF NOT EXISTS "indexer_locked" (
	"_cursor" bigint,
	"created_at" timestamp,
	"network" "network_type",
	"block_hash" text,
	"block_number" bigint,
	"block_timestamp" timestamp,
	"transaction_hash" text,
	"index_in_block" bigint,
	"id" text PRIMARY KEY NOT NULL,
	"token_address" text,
	"from_address" text,
	"amount" text
);
--> statement-breakpoint
CREATE TABLE IF NOT EXISTS "indexer_unlocked" (
	"_cursor" bigint,
	"created_at" timestamp,
	"network" "network_type",
	"block_hash" text,
	"block_number" bigint,
	"block_timestamp" timestamp,
	"transaction_hash" text,
	"index_in_block" bigint,
	"id" text PRIMARY KEY NOT NULL,
	"token_address" text,
	"from_address" text,
	"to_address" text,
	"amount" text
);
--> statement-breakpoint
CREATE INDEX IF NOT EXISTS "locked_cursor_idx" ON "indexer_locked" USING btree ("_cursor");--> statement-breakpoint
CREATE INDEX IF NOT EXISTS "locked_token_idx" ON "indexer_locked" USING btree ("token_address");--> statement-breakpoint
CREATE INDEX IF NOT EXISTS "locked_from_idx" ON "indexer_locked" USING btree ("from_address");--> statement-breakpoint
CREATE INDEX IF NOT EXISTS "unlocked_cursor_idx" ON "indexer_unlocked" USING btree ("_cursor");--> statement-breakpoint
CREATE INDEX IF NOT EXISTS "unlocked_token_idx" ON "indexer_unlocked" USING btree ("token_address");--> statement-breakpoint
CREATE INDEX IF NOT EXISTS "unlocked_from_idx" ON "indexer_unlocked" USING btree ("from_address");--> statement-breakpoint
CREATE INDEX IF NOT EXISTS "unlocked_to_idx" ON "indexer_unlocked" USING btree ("to_address");