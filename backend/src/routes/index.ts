import type { FastifyInstance } from 'fastify'

import { getHealthRoute } from './getHealth'
import { getOnrampQuotes } from './getOnrampQuotes'

export function declareRoutes(fastify: FastifyInstance) {
  getHealthRoute(fastify)
  getOnrampQuotes(fastify)
}
