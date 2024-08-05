import { StrictMode } from 'react'
import { createRoot } from 'react-dom/client'
import { BrowserRouter } from 'react-router-dom'
import ThemeProvider, { ThemedGlobalStyle } from 'src/theme/index'

import App from './App'

const container = document.getElementById('root')
if (!container) throw 'Undefined #root container'

const root = createRoot(container)
root.render(
  <StrictMode>
    <BrowserRouter>
      <ThemeProvider>
        <ThemedGlobalStyle />
        <App />
      </ThemeProvider>
    </BrowserRouter>
  </StrictMode>
)
