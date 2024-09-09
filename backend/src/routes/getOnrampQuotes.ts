import type { FastifyInstance, FastifyRequest, FastifyReply } from 'fastify'
import { locked } from '@/db/schema'

import type { Database } from '@/db/drizzle'

export function getOnrampQuotes(fastify: FastifyInstance) {
  fastify.get('/get-onramp-quotes', async (request, reply) => handleGetOnrampQuotes(fastify.db, request, reply))
}

async function handleGetOnrampQuotes(db: Database, _request: FastifyRequest, reply: FastifyReply) {
  try {
    const onRampQuotes = await db.select({ amount: locked.amount }).from(locked)

    return reply.send({ onRampQuotes })
  } catch (error) {
    console.error(error)
    return reply.status(500).send({ message: 'Internal server error' })
  }
}
