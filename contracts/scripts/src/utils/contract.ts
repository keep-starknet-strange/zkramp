import signale from 'signale'
import { Calldata } from 'starknet'

import { account } from '../services/account'
import { Contract } from '../types/contract'

export const declareContract = async (contract: Contract) => {
  signale.info(`Declaring ${contract.name} contract...`)

  const transaction = await account.declareIfNot({
    contract: contract.classFile,
    casm: contract.compiledClassFile,
  })

  signale.pending(`- Class Hash: ${transaction.class_hash}`)

  if (transaction.transaction_hash) {
    signale.pending(`- Transaction Hash: ${transaction.transaction_hash}`)

    await account.waitForTransaction(transaction.transaction_hash)

    signale.success(`Contract ${contract.name} declared successfully!`)
  } else {
    signale.success(`Contract ${contract.name} already declared!`)
  }

  return transaction.class_hash
}

export const deployContract = async (contract: Contract, classHash: string, constructorCalldata: Calldata) => {
  signale.info(`Deploying ${contract.name} contract...`)

  const transaction = await account.deployContract({
    classHash,
    constructorCalldata,
  })

  signale.pending(`- Transaction Hash: ${transaction.transaction_hash}`)

  await account.waitForTransaction(transaction.transaction_hash)

  signale.success(`Contract ${contract.name} deployed successfully!`)

  return transaction
}

export const declareAndDeployContract = async (contract: Contract, constructorCalldata: Calldata) => {
  const classHash = await declareContract(contract)
  return deployContract(contract, classHash, constructorCalldata)
}
