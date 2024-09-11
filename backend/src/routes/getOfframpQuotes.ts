import type { FastifyInstance, FastifyReply, FastifyRequest } from 'fastify'

import type { Database } from '@/db/drizzle'
import { locked } from '@/db/schema'

export function getOfframpQuotes(fastify: FastifyInstance) {
  fastify.get('/get-offramp-quotes', async (request, reply) => handleGetOfframpQuotes(fastify.db, request, reply))
}

async function handleGetOfframpQuotes(db: Database, _request: FastifyRequest, reply: FastifyReply) {
  try {
    const offRampQuotes = await db.select({ amount: locked.amount }).from(locked)

    return reply.send({ offRampQuotes })
  } catch (error) {
    console.error(error)
    return reply.status(500).send({ message: 'Internal server error' })
  }
}
