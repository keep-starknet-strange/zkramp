import { sql } from 'drizzle-orm'
import type { Database } from '@/db/drizzle'
import type { FastifyInstance } from 'fastify'

export function getHealthRoute(fastify: FastifyInstance) {
  fastify.get('/health', async () => handleGetHealth(fastify.db))
}

async function handleGetHealth(db: Database) {
  // Check that the database is reachable.
  const query = sql`SELECT 1`
  await db.execute(query)

  return { status: 'OK' }
}
