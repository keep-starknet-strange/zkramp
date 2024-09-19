DO $$ BEGIN
 CREATE TYPE "public"."ramp_type" AS ENUM('Revolut');
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;
--> statement-breakpoint
CREATE TABLE IF NOT EXISTS "indexer_liquidity_added" (
	"_cursor" bigint,
	"created_at" timestamp,
	"network" "network_type",
	"block_hash" text,
	"block_number" bigint,
	"block_timestamp" timestamp,
	"transaction_hash" text,
	"index_in_block" bigint,
	"id" text PRIMARY KEY NOT NULL,
	"ramp" "ramp_type",
	"owner_address" text,
	"offchain_id" text,
	"amount" text
);
--> statement-breakpoint
CREATE TABLE IF NOT EXISTS "indexer_liquidity_locked" (
	"_cursor" bigint,
	"created_at" timestamp,
	"network" "network_type",
	"block_hash" text,
	"block_number" bigint,
	"block_timestamp" timestamp,
	"transaction_hash" text,
	"index_in_block" bigint,
	"id" text PRIMARY KEY NOT NULL,
	"ramp" "ramp_type",
	"owner_address" text,
	"offchain_id" text
);
--> statement-breakpoint
CREATE TABLE IF NOT EXISTS "indexer_liquidity_retrieved" (
	"_cursor" bigint,
	"created_at" timestamp,
	"network" "network_type",
	"block_hash" text,
	"block_number" bigint,
	"block_timestamp" timestamp,
	"transaction_hash" text,
	"index_in_block" bigint,
	"id" text PRIMARY KEY NOT NULL,
	"ramp" "ramp_type",
	"owner_address" text,
	"offchain_id" text,
	"amount" text
);
--> statement-breakpoint
CREATE INDEX IF NOT EXISTS "liquidity_added_cursor_idx" ON "indexer_liquidity_added" USING btree ("_cursor");--> statement-breakpoint
CREATE INDEX IF NOT EXISTS "liquidity_added_token_idx" ON "indexer_liquidity_added" USING btree ("ramp");--> statement-breakpoint
CREATE INDEX IF NOT EXISTS "liquidity_added_owner_idx" ON "indexer_liquidity_added" USING btree ("owner_address");--> statement-breakpoint
CREATE INDEX IF NOT EXISTS "liquidity_added_offchain_id_idx" ON "indexer_liquidity_added" USING btree ("offchain_id");--> statement-breakpoint
CREATE INDEX IF NOT EXISTS "liquidity_locked_cursor_idx" ON "indexer_liquidity_locked" USING btree ("_cursor");--> statement-breakpoint
CREATE INDEX IF NOT EXISTS "liquidity_locked_token_idx" ON "indexer_liquidity_locked" USING btree ("ramp");--> statement-breakpoint
CREATE INDEX IF NOT EXISTS "liquidity_locked_owner_idx" ON "indexer_liquidity_locked" USING btree ("owner_address");--> statement-breakpoint
CREATE INDEX IF NOT EXISTS "liquidity_locked_offchain_id_idx" ON "indexer_liquidity_locked" USING btree ("offchain_id");--> statement-breakpoint
CREATE INDEX IF NOT EXISTS "liquidity_retrieved_cursor_idx" ON "indexer_liquidity_retrieved" USING btree ("_cursor");--> statement-breakpoint
CREATE INDEX IF NOT EXISTS "liquidity_retrieved_token_idx" ON "indexer_liquidity_retrieved" USING btree ("ramp");--> statement-breakpoint
CREATE INDEX IF NOT EXISTS "liquidity_retrieved_owner_idx" ON "indexer_liquidity_retrieved" USING btree ("owner_address");--> statement-breakpoint
CREATE INDEX IF NOT EXISTS "liquidity_retrieved_offchain_id_idx" ON "indexer_liquidity_retrieved" USING btree ("offchain_id");