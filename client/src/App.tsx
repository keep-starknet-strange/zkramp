import { createBrowserRouter, RouterProvider } from 'react-router-dom'
import Layout from 'src/components/Layout'

import RegisterPage from './pages/RegisterPage'
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
  {
    path: '/register',
    element: (
      <Layout>
        <RegisterPage />
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
