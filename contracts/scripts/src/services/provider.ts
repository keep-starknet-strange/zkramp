import { RpcProvider, type RpcProviderOptions } from 'starknet'
import signale from 'signale'

if (!process.env.INFURA_API_KEY) {
  signale.fatal(new Error('INFURA_API_KEY env variable is required'))
  process.exit(1)
}

if (!process.env.NETWORK) {
  signale.fatal(new Error('NETWORK env variable is required'))
  process.exit(1)
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
  signale.fatal(new Error(`Unsupported network: ${process.env.NETWORK}`))
  process.exit(1)
}

export const provider = new RpcProvider(network)
