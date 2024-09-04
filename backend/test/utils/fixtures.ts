import { PostgreSqlContainer, type StartedPostgreSqlContainer } from '@testcontainers/postgresql'
import type { FastifyInstance } from 'fastify'

import { buildApp } from '@/app'

export async function startTestAppInstance() {
  const container = await new PostgreSqlContainer().start()

  const app = await buildApp({
    database: {
      connectionString: container.getConnectionUri(),
    },
    app: {
      port: 8080,
    },
  })

  await app.ready()

  return { container, app }
}

export async function stopTestAppInstance(container: StartedPostgreSqlContainer, app: FastifyInstance) {
  await app?.close()
  await container?.stop()
}
