import dotenv from 'dotenv'
import Fastify, { type FastifyInstance } from 'fastify'

import { fastifyDrizzle } from '@/db/plugin'

import { declareRoutes } from './routes'

export type AppConfiguration = {
  database: {
    connectionString: string
  }
  app: {
    port: number
    host?: string
  }
}

export async function buildApp(config: AppConfiguration): Promise<FastifyInstance> {
  const app = Fastify({ logger: true })

  dotenv.config()
  app.register(fastifyDrizzle, {
    connectionString: config.database.connectionString,
  })

  // Declare routes
  declareRoutes(app)

  return app
}

export async function buildAndStartApp(config: AppConfiguration) {
  const app = await buildApp(config)

  try {
    await app.listen({ port: config.app.port, host: config.app.host })
    console.log(`Server listening on port ${config.app.port}`)
  } catch (err) {
    console.error(err)
    process.exit(1)
  }
}
