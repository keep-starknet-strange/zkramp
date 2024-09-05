import { apibara, starknet } from './utils/deps.ts'
import { ESCROW_ADDRESS, STARTING_BLOCK } from './utils/constants.ts'
import { getCommonValues } from './utils/helpers.ts'

const filter = {
  header: {
    weak: true,
  },
  events: [
    {
      fromAddress: ESCROW_ADDRESS,
      keys: [starknet.hash.getSelectorFromName('UnLocked')],
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

export default function transform({ header, events }: apibara.Block) {
  return (events ?? [])
    .map(({ event, transaction }) => {
      if (!event.data || !event.keys) return null

      const tokenAddress = event.keys[1]
      const [fromAddress, toAddress, amountLow, amountHigh] = event.data

      const amount = starknet.uint256.uint256ToBN({
        low: amountLow,
        high: amountHigh,
      })

      return {
        ...getCommonValues(header!, event, transaction),

        token_address: tokenAddress,
        from_address: fromAddress,
        to_address: toAddress,
        amount: amount.toString(),
      }
    })
    .filter(Boolean)
}
