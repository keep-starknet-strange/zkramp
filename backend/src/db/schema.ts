import { bigint, pgEnum, pgTable, text, timestamp } from 'drizzle-orm/pg-core'

export const networkEnum = pgEnum('network_type', ['mainnet', 'sepolia'])

const indexerCommonSchema = {
  cursor: bigint('_cursor', { mode: 'number' }),
  createdAt: timestamp('created_at', { mode: 'date', withTimezone: false }),

  network: networkEnum('network'),
  blockHash: text('block_hash'),
  blockNumber: bigint('block_number', { mode: 'number' }),
  blockTimestamp: timestamp('block_timestamp', {
    mode: 'date',
    withTimezone: false,
  }),
  transactionHash: text('transaction_hash'),
}
