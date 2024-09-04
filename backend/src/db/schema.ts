import { bigint, pgTable, text, timestamp } from "drizzle-orm/pg-core";

const commonSchema = {
  cursor: bigint("_cursor", { mode: "number" }),
  createdAt: timestamp("created_at", { mode: "date", withTimezone: false }),

  network: text("network"),
  blockHash: text("block_hash"),
  blockNumber: bigint("block_number", { mode: "number" }),
  blockTimestamp: timestamp("block_timestamp", {
    mode: "date",
    withTimezone: false,
  }),
  transactionHash: text("transaction_hash"),
};
