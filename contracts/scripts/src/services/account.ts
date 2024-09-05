import { Account } from 'starknet'
import signale from 'signale'

import { provider } from './provider'

if (!process.env.ACCOUNT_ADDRESS) {
  signale.fatal(new Error('ACCOUNT_ADDRESS env variable is required'))
  process.exit(1)
}

if (!process.env.ACCOUNT_PRIVATE_KEY) {
  signale.fatal(new Error('ACCOUNT_PRIVATE_KEY env variable is required'))
  process.exit(1)
}

export const account = new Account(provider, process.env.ACCOUNT_ADDRESS, process.env.ACCOUNT_PRIVATE_KEY, '1')
