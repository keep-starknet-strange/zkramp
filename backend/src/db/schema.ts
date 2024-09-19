import { bigint, index, pgEnum, pgTable, text, timestamp } from 'drizzle-orm/pg-core'

export const networkEnum = pgEnum('network_type', ['mainnet', 'sepolia'])

export const rampEnum = pgEnum('ramp_type', ['Revolut'])

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

export const liquidityAdded = pgTable(
  'indexer_liquidity_added',
  {
    ...indexerCommonSchema,

    id: text('id').primaryKey(),

    ramp: rampEnum('ramp'),
    owner: text('owner_address'),
    offchainId: text('offchain_id'),
    amount: text('amount'),
  },
  (table) => {
    return {
      cursorIdx: index('liquidity_added_cursor_idx').on(table.cursor),
      rampIdx: index('liquidity_added_token_idx').on(table.ramp),
      ownerIdx: index('liquidity_added_owner_idx').on(table.owner),
      offchainIdIdx: index('liquidity_added_offchain_id_idx').on(table.offchainId),
    }
  },
)

export const liquidityLocked = pgTable(
  'indexer_liquidity_locked',
  {
    ...indexerCommonSchema,

    id: text('id').primaryKey(),

    ramp: rampEnum('ramp'),
    owner: text('owner_address'),
    offchainId: text('offchain_id'),
  },
  (table) => {
    return {
      cursorIdx: index('liquidity_locked_cursor_idx').on(table.cursor),
      rampIdx: index('liquidity_locked_token_idx').on(table.ramp),
      ownerIdx: index('liquidity_locked_owner_idx').on(table.owner),
      offchainIdIdx: index('liquidity_locked_offchain_id_idx').on(table.offchainId),
    }
  },
)

export const liquidityRetrieved = pgTable(
  'indexer_liquidity_retrieved',
  {
    ...indexerCommonSchema,

    id: text('id').primaryKey(),

    ramp: rampEnum('ramp'),
    owner: text('owner_address'),
    offchainId: text('offchain_id'),
    amount: text('amount'),
  },
  (table) => {
    return {
      cursorIdx: index('liquidity_retrieved_cursor_idx').on(table.cursor),
      rampIdx: index('liquidity_retrieved_token_idx').on(table.ramp),
      ownerIdx: index('liquidity_retrieved_owner_idx').on(table.owner),
      offchainIdIdx: index('liquidity_retrieved_offchain_id_idx').on(table.offchainId),
    }
  },
)
