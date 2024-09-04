import type { FastifyPluginCallback } from 'fastify'
import { fastifyPlugin } from 'fastify-plugin'
import postgres from 'postgres'

import { drizzle, migrate } from './drizzle'

type FastifyDrizzleOptions = {
  connectionString: string
}

const plugin: FastifyPluginCallback<FastifyDrizzleOptions> = (fastify, opts: FastifyDrizzleOptions, next) => {
  if (!opts.connectionString) {
    return next(new Error('connectionString is required'))
  }

  // Hook postgres notices to the Fastify logger.
  const onnotice = (msg: postgres.Notice) => {
    fastify.log.info(msg)
  }

  const pool = postgres(opts.connectionString, {
    onnotice,
  })

  const db = drizzle(pool)

  fastify.decorate('db', db).addHook('onReady', async () => {
    fastify.log.info('Database migration started')

    // Migration requires a single connection to work.
    const client = postgres(opts.connectionString, { max: 1, onnotice })
    await migrate(client)

    fastify.log.info('Database migration finished')
  })

  next()
}

export const fastifyDrizzle = fastifyPlugin(plugin)
