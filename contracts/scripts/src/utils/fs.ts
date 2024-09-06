import { dirname, join } from 'node:path'
import fs from 'node:fs/promises'
import { existsSync } from 'node:fs'
import { fileURLToPath } from 'node:url'
import signale from 'signale'
import { json } from 'starknet'

import { Contract } from '../types/contract'

const __filename = fileURLToPath(import.meta.url)
const __dirname = dirname(__filename)

export const TARGET_PATH = join(__dirname, '..', '..', 'target', 'dev')

export const getContracts = async () => {
  if (!existsSync(TARGET_PATH)) {
    signale.error(`Target directory could not be found at ${TARGET_PATH}. Please run "scarb build" first.`)
    process.exit(1)
  }

  const contracts = (await fs.readdir(TARGET_PATH))
    .filter((file) => file.endsWith('.contract_class.json'))
    .map((file) => file.replace('.contract_class.json', ''))

  if (contracts.length === 0) {
    signale.error('No contracts found in the target directory. Please run "scarb build" first.')
    process.exit(1)
  }

  return contracts
}

export const getContract = async (contractName: string): Promise<Contract> => {
  const contracts = await getContracts()

  const contract = contracts.find((contract) => contract.includes(contractName))

  if (!contract) {
    signale.error(`Contract ${contractName} not found in the target directory. Please run "scarb build" first.`)
    process.exit(1)
  }

  const classPath = join(TARGET_PATH, `${contract}.contract_class.json`)
  const compiledClassPath = join(TARGET_PATH, `${contract}.compiled_contract_class.json`)

  return {
    name: contractName,
    classPath,
    compiledClassPath,
    classFile: json.parse(await fs.readFile(classPath, 'ascii')),
    compiledClassFile: json.parse(await fs.readFile(compiledClassPath, 'ascii')),
  }
}
