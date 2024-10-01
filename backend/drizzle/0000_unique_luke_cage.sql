DO $$ BEGIN
 CREATE TYPE "public"."network_type" AS ENUM('mainnet', 'sepolia');
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;
--> statement-breakpoint
DO $$ BEGIN
 CREATE TYPE "public"."ramp_type" AS ENUM('Revolut');
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;
--> statement-breakpoint
CREATE TABLE IF NOT EXISTS "liquidity" (
	"owner" text,
	"offchain_id" text,
	"locked" boolean DEFAULT false,
	"amount" bigint,
	"_cursor" "int8range" NOT NULL,
	CONSTRAINT "liquidity_key" PRIMARY KEY("owner","offchain_id")
);
--> statement-breakpoint
CREATE TABLE IF NOT EXISTS "liquidity_request" (
	"owner" text,
	"offchain_id" text,
	"requestor" text,
	"requestor_offchain_id" text,
	"amount" bigint NOT NULL,
	"expires_at" timestamp NOT NULL,
	"_cursor" bigint
);
--> statement-breakpoint
CREATE TABLE IF NOT EXISTS "registration" (
	"address" text PRIMARY KEY NOT NULL,
	"revolut" text[] DEFAULT ARRAY[]::text[] NOT NULL
);
--> statement-breakpoint
DO $$ BEGIN
 ALTER TABLE "liquidity_request" ADD CONSTRAINT "liquidity_key" FOREIGN KEY ("owner","offchain_id") REFERENCES "public"."liquidity"("owner","offchain_id") ON DELETE no action ON UPDATE no action;
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;
