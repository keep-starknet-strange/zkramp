import type { FastifyInstance } from 'fastify'

import { getHealthRoute } from './getHealth'

export function declareRoutes(fastify: FastifyInstance) {
  getHealthRoute(fastify)
}
