import { Level } from 'level'

import mutex from './mutex'

const db = new Level('./ext-db', {
  valueEncoding: 'json',
})
const connectionDb = db.sublevel<string, boolean>('connections', {
  valueEncoding: 'json',
})

export async function setConnection(origin: string) {
  if (await getConnection(origin)) return null
  await connectionDb.put(origin, true)
  return true
}

export async function deleteConnection(origin: string) {
  return mutex.runExclusive(async () => {
    if (await getConnection(origin)) {
      await connectionDb.del(origin)
    }
  })
}

export async function getConnection(origin: string) {
  try {
    const existing = await connectionDb.get(origin)
    return existing
  } catch (e) {
    return null
  }
}
