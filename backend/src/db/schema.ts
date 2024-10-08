import { sql } from 'drizzle-orm'
import { bigint, boolean, foreignKey, pgEnum, pgTable, primaryKey, text, timestamp } from 'drizzle-orm/pg-core'

import { int8range } from './int8range'

export const networkEnum = pgEnum('network_type', ['mainnet', 'sepolia'])

export const rampEnum = pgEnum('ramp_type', ['Revolut'])

export const registration = pgTable('registration', {
  address: text('address').primaryKey(),
  revolut: text('revolut')
    .array()
    .notNull()
    .default(sql`ARRAY[]::text[]`),
})

export const liquidity = pgTable(
  'liquidity',
  {
    owner: text('owner'),
    offchainId: text('offchain_id'),
    locked: boolean('locked').default(false),
    amount: bigint('amount', { mode: 'bigint' }),
    cursor: int8range('_cursor').notNull(),
  },
  (table) => {
    return {
      liquidityKey: primaryKey({ name: 'liquidity_key', columns: [table.owner, table.offchainId] }),
    }
  },
)

export const liquidityRequest = pgTable(
  'liquidity_request',
  {
    owner: text('owner'),
    offchainId: text('offchain_id'),
    requestor: text('requestor'),
    requestorOffchainId: text('requestor_offchain_id'),
    amount: bigint('amount', { mode: 'bigint' }).notNull(),
    expiresAt: timestamp('expires_at').notNull(),
    cursor: bigint('_cursor', { mode: 'number' }),
  },
  (table) => {
    return {
      liquidityKey: foreignKey({
        columns: [table.owner, table.offchainId],
        foreignColumns: [liquidity.owner, liquidity.offchainId],
        name: 'liquidity_key',
      }),
    }
  },
)
