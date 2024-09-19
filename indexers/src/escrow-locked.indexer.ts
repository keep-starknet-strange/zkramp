import { apibara, starknet } from './utils/deps.ts'
import { ESCROW_ADDRESS, ESCROW_STARTING_BLOCK } from './utils/constants.ts'
import { getCommonValues } from './utils/helpers.ts'

const filter = {
  header: {
    weak: true,
  },
  events: [
    {
      fromAddress: ESCROW_ADDRESS,
      keys: [starknet.hash.getSelectorFromName('Locked')],
      includeReceipt: false,
    },
  ],
}

export const config = {
  streamUrl: 'https://mainnet.starknet.a5a.ch',
  startingBlock: ESCROW_STARTING_BLOCK,
  network: 'starknet',
  finality: 'DATA_STATUS_ACCEPTED',
  filter,
  sinkType: 'postgres',
  sinkOptions: {
    tableName: 'indexer_locked',
  },
}

export default function transform({ header, events }: apibara.Block) {
  return (events ?? [])
    .map(({ event, transaction }) => {
      if (!event.data || !event.keys) return null

      const eventId = `${transaction.meta.hash}_${event.index ?? 0}`

      const tokenAddress = event.keys[1]
      const [fromAddress, amountLow, amountHigh] = event.data

      const amount = starknet.uint256.uint256ToBN({
        low: amountLow,
        high: amountHigh,
      })

      return {
        ...getCommonValues(header!, event, transaction),

        id: eventId,

        token_address: tokenAddress,
        from_address: fromAddress,
        amount: amount.toString(),
      }
    })
    .filter(Boolean)
}
