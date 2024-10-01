import { apibara, starknet } from './utils/deps.ts'
import { LIQUIDITY_VAR_NAME, REVOLUT_ADDRESSES, SN_CHAIN_ID, STARTING_BLOCK, STREAM_URLS } from './utils/constants.ts'
import { getLiquidityKeyMapStorageLocation } from './utils/helpers.ts'
import { LiquidityKey } from './utils/types.ts';

const filter = {
  header: {
    weak: true,
  },
  events: [
    {
      fromAddress: REVOLUT_ADDRESSES[SN_CHAIN_ID],
      keys: [starknet.hash.getSelectorFromName('LiquidityAdded')],
      includeReceipt: false,
    },
  ],
	stateUpdate: {
		storageDiffs: [{ contractAddress: REVOLUT_ADDRESSES[SN_CHAIN_ID] }],
	},
}

const streamUrl = STREAM_URLS[SN_CHAIN_ID]
const startingBlock = STARTING_BLOCK

export const config = {
	streamUrl,
	startingBlock,
	network: 'starknet',
	finality: 'DATA_STATUS_PENDING',
	filter,
	sinkType: 'postgres',
	sinkOptions: {
		tableName: 'liquidity',
    entityMode: true,
	},
}

function getLiquidity(storageMap: Map<bigint, bigint>, liquidityKey: LiquidityKey): bigint {
	const liquidityAmountLocation = getLiquidityKeyMapStorageLocation(LIQUIDITY_VAR_NAME, liquidityKey)

	const addressBalanceLow = storageMap.get(liquidityAmountLocation)
	const addressBalanceHigh = storageMap.get(liquidityAmountLocation + 1n)

	return starknet.uint256.uint256ToBN({
		low: addressBalanceLow ?? 0n,
		high: addressBalanceHigh ?? 0n,
	})
}

export default function transform({ events, stateUpdate }: apibara.Block) {
	// Step 1: map state updates.
	const storageMap = new Map<bigint, bigint>()
	const storageDiffs = stateUpdate?.stateDiff?.storageDiffs ?? []

	for (const storageDiff of storageDiffs) {
		for (const storageEntry of storageDiff.storageEntries ?? []) {
			if (!storageEntry.key || !storageEntry.value) {
				continue
			}

			const key = BigInt(storageEntry.key)
			const value = BigInt(storageEntry.value)

			storageMap.set(key, value)
		}
	}

	// Step 2: aggregate everyting
  return (events ?? [])
    .map(({ event }) => {
      if (!event.data || !event.keys) return null

      const [, owner, offchainIdPlateform, offchainIdValue] = event.keys

      const offchainId = `${offchainIdPlateform}@${offchainIdValue}`

      const liquidityKey = {
        offchainId: {
          plateform: +offchainIdPlateform,
          id: offchainIdValue
        },
        owner
      }

      const amount = getLiquidity(storageMap, liquidityKey)

      return {
        owner,
        offchainId,
        locked: false,
        amount,
      }
    })
    .filter(Boolean)
}
