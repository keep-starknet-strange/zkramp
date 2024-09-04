/* eslint-disable import/no-unused-modules */

import tsconfigPaths from 'vite-tsconfig-paths'
import { defineConfig } from 'vitest/config'

export default defineConfig({
  plugins: [tsconfigPaths()],
  test: {
    hookTimeout: 50_000,
    coverage: {
      provider: 'istanbul',
      reporter: ['text', 'json-summary', 'json'],
    },
  },
})
