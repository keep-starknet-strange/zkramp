import { STORAGE_ADDRESS_BOUND } from './constants.ts'
import { starknet } from './deps.ts'
import { LiquidityKey } from './types.ts'

export function getLiquidityKeyMapStorageLocation(varName: string, liquidityKey: LiquidityKey) {
  const hashedVarName = starknet.hash.getSelectorFromName(varName)
  const serializedLiquidityKey = [liquidityKey.owner, liquidityKey.offchainId.plateform, liquidityKey.offchainId.id]

  const location = BigInt([serializedLiquidityKey.length, ...serializedLiquidityKey]
    .reduce<string>((x, y) => starknet.ec.starkCurve.pedersen(x, y), hashedVarName))

  return location >= STORAGE_ADDRESS_BOUND ? location - STORAGE_ADDRESS_BOUND : location
}
