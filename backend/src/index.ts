import 'dotenv/config'

import { type AppConfiguration, buildAndStartApp } from '@/app'

const config: AppConfiguration = {
  database: {
    connectionString: process.env.DATABASE_URL || 'postgres://localhost:5432/postgres',
  },
  app: {
    host: process.env.HOST || '127.0.0.1',
    port: Number.parseInt(process.env.PORT || '8080'),
  },
}

buildAndStartApp(config)
