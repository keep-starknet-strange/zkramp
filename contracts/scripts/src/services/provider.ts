import { RpcProvider, type RpcProviderOptions } from 'starknet'

if (!process.env.INFURA_API_KEY) {
  throw new Error('INFURA_API_KEY env variable is required')
}

if (!process.env.NETWORK) {
  throw new Error('NETWORK env variable is required')
}

const NETWORKS = {
  mainnet: {
    nodeUrl: `https://starknet-mainnet.infura.io/v3/${process.env.INFURA_API_KEY}`,
  },
  sepolia: {
    nodeUrl: `https://starknet-sepolia.infura.io/v3/${process.env.INFURA_API_KEY}`,
  },
} satisfies Record<string, RpcProviderOptions>

export const network = NETWORKS[process.env.NETWORK as keyof typeof NETWORKS]

if (!network) {
  throw new Error(`Unsupported network: ${process.env.NETWORK}`)
}

export const provider = new RpcProvider(network)
