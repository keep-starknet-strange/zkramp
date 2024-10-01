import { starknet } from './deps.ts'

// Order should match the order in the contract
export enum Plateform {
  Revolut = 0,
}

export const STORAGE_ADDRESS_BOUND = 2n ** 251n

type SupportedChainId = Exclude<starknet.constants.StarknetChainId, typeof starknet.constants.StarknetChainId.SN_GOERLI>

type AddressesMap = Record<SupportedChainId, string>

export const REVOLUT_ADDRESSES: AddressesMap = {
  [starknet.constants.StarknetChainId.SN_MAIN]: '0x0',
  [starknet.constants.StarknetChainId.SN_SEPOLIA]: '0x0',
}

const DEFAULT_NETWORK_NAME = starknet.constants.NetworkName.SN_SEPOLIA

export const SN_CHAIN_ID =
  (starknet.constants.StarknetChainId[(Deno.env.get('SN_NETWORK') ?? '') as starknet.constants.NetworkName] ??
  starknet.constants.StarknetChainId[DEFAULT_NETWORK_NAME]) as SupportedChainId

export const STREAM_URLS = {
  [starknet.constants.StarknetChainId.SN_MAIN]: 'https://mainnet.starknet.a5a.ch',
  [starknet.constants.StarknetChainId.SN_SEPOLIA]: 'https://sepolia.starknet.a5a.ch',
}

export const STARTING_BLOCK = Number(Deno.env.get('STARTING_BLOCK')) ?? 0

export const LIQUIDITY_VAR_NAME = 'liquidity'
