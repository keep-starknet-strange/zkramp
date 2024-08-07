import { createBrowserRouter, RouterProvider } from 'react-router-dom'
import Layout from 'src/components/Layout'

import SwapPage from './pages/Swap'
import StarknetProvider from './providers/StarknetProvider'

const router = createBrowserRouter([
  {
    path: '/',
    element: (
      <Layout>
        <SwapPage />
      </Layout>
    ),
  },
])

export default function App() {
  return (
    <StarknetProvider>
      <RouterProvider router={router} />
    </StarknetProvider>
  )
}
