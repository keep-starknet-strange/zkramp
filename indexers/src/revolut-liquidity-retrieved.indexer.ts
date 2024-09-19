import { apibara, starknet } from './utils/deps.ts'
import { RAMPS, REVOLUT_ADDRESS, REVOLUT_STARTING_BLOCK } from './utils/constants.ts'
import { getCommonValues } from './utils/helpers.ts'

const filter = {
  header: {
    weak: true,
  },
  events: [
    {
      fromAddress: REVOLUT_ADDRESS,
      keys: [starknet.hash.getSelectorFromName('LiquidityRetrieved')],
      includeReceipt: false,
    },
  ],
}

export const config = {
  streamUrl: 'https://mainnet.starknet.a5a.ch',
  startingBlock: REVOLUT_STARTING_BLOCK,
  network: 'starknet',
  finality: 'DATA_STATUS_ACCEPTED',
  filter,
  sinkType: 'postgres',
  sinkOptions: {
    tableName: 'indexer_liquidity_retrieved',
  },
}

export default function transform({ header, events }: apibara.Block) {
  return (events ?? [])
    .map(({ event, transaction }) => {
      if (!event.data || !event.keys) return null

      const eventId = `${transaction.meta.hash}_${event.index ?? 0}`

      const [, owner, ramp_idx, offchain_id] = event.keys
      const [amountLow, amountHigh] = event.data

      const ramp = Object.values(RAMPS)[Number(ramp_idx)]
      if (!ramp) return null

      const amount = starknet.uint256.uint256ToBN({
        low: amountLow,
        high: amountHigh,
      })

      return {
        ...getCommonValues(header!, event, transaction),

        id: eventId,

        ramp,
        owner_address: owner,
        offchain_id,
        amount: amount.toString(),
      }
    })
    .filter(Boolean)
}
