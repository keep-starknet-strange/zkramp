import type { Database } from '../db/drizzle'

declare module 'fastify' {
  interface FastifyInstance {
    db: Database
  }
}
