import { apibara, starknet } from './utils/deps.ts'
import { ESCROW_ADDRESS, STARTING_BLOCK } from './utils/constants.ts'

const filter = {
  header: {
    weak: true,
  },
  events: [
    {
      fromAddress: ESCROW_ADDRESS,
      keys: [starknet.hash.getSelectorFromName('')],
      includeReceipt: false,
    },
  ],
}

export const config = {
  streamUrl: 'https://mainnet.starknet.a5a.ch',
  startingBlock: STARTING_BLOCK,
  network: 'starknet',
  finality: 'DATA_STATUS_ACCEPTED',
  filter,
  sinkType: 'postgres',
  sinkOptions: {
    tableName: 'indexer_unlocked',
  },
}

export default function DecodeUnruggableMemecoinLaunch({ header, events }: apibara.Block) {
  const { blockNumber, blockHash, timestamp } = header!

  return []
}
