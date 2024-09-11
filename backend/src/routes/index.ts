import type { FastifyInstance } from 'fastify'

import { getHealthRoute } from './getHealth'
import { getOfframpQuotes } from './getOfframpQuotes'

export function declareRoutes(fastify: FastifyInstance) {
  getHealthRoute(fastify)
  getOfframpQuotes(fastify)
}
