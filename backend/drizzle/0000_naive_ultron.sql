DO $$ BEGIN
 CREATE TYPE "public"."network_type" AS ENUM('mainnet', 'sepolia');
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;
