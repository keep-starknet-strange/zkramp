import { apibara } from './deps.ts'

export const getCommonValues = (
  header: apibara.BlockHeader,
  event: apibara.Event,
  transaction: apibara.Transaction
) => {
  const { blockNumber, blockHash, timestamp } = header

  const transactionHash = transaction.meta.hash
  const eventId = `${transactionHash}_${event.index ?? 0}`
  const IndexInBlock = (transaction.meta.transactionIndex ?? 0) * 1_000 + (event.index ?? 0)

  return {
    created_at: new Date().toISOString(),
    network: 'mainnet',
    block_hash: blockHash,
    block_number: +(blockNumber ?? 0),
    block_timestamp: timestamp,
    transaction_hash: transactionHash,
    index_in_block: IndexInBlock,

    id: eventId,
  }
}
