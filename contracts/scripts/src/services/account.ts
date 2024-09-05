import { Account } from 'starknet'
import { provider } from './provider'

if (!process.env.ACCOUNT_ADDRESS) {
  throw new Error('ACCOUNT_ADDRESS env variable is required')
}

if (!process.env.ACCOUNT_PRIVATE_KEY) {
  throw new Error('ACCOUNT_PRIVATE_KEY env variable is required')
}

export const account = new Account(provider, process.env.ACCOUNT_ADDRESS, process.env.ACCOUNT_PRIVATE_KEY, '1')
