import { type StartedPostgreSqlContainer } from '@testcontainers/postgresql'
import { type FastifyInstance } from 'fastify'
import { afterAll, beforeAll, describe, expect, test } from 'vitest'

import { startTestAppInstance, stopTestAppInstance } from './utils/fixtures'

describe('GET /health route', () => {
  let container: StartedPostgreSqlContainer
  let app: FastifyInstance

  beforeAll(async () => {
    ;({ container, app } = await startTestAppInstance())
  })

  afterAll(async () => {
    await stopTestAppInstance(container, app)
  })

  test('should return success', async () => {
    const response = await app.inject({
      method: 'GET',
      url: '/health',
    })

    expect(response.statusCode).toBe(200)
  })
})
