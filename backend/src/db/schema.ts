import { bigint, index, pgEnum, pgTable, text, timestamp } from 'drizzle-orm/pg-core'

export const networkEnum = pgEnum('network_type', ['mainnet', 'sepolia'])

// eslint-disable-next-line @typescript-eslint/no-unused-vars
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
  indexInBlock: bigint('index_in_block', { mode: 'number' }),
}

export const locked = pgTable(
  'indexer_locked',
  {
    ...indexerCommonSchema,

    id: text('id').primaryKey(),

    token: text('token_address'),
    from: text('from_address'),
    amount: text('amount'),
  },
  (table) => {
    return {
      cursorIdx: index('locked_cursor_idx').on(table.cursor),
      tokenIdx: index('locked_token_idx').on(table.token),
      fromIdx: index('locked_from_idx').on(table.from),
    }
  },
)

export const unlocked = pgTable(
  'indexer_unlocked',
  {
    ...indexerCommonSchema,

    id: text('id').primaryKey(),

    token: text('token_address'),
    from: text('from_address'),
    to: text('to_address'),
    amount: text('amount'),
  },
  (table) => {
    return {
      cursorIdx: index('unlocked_cursor_idx').on(table.cursor),
      tokenIdx: index('unlocked_token_idx').on(table.token),
      fromIdx: index('unlocked_from_idx').on(table.from),
      toIdx: index('unlocked_to_idx').on(table.to),
    }
  },
)
