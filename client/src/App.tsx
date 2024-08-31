import { createBrowserRouter, RouterProvider } from 'react-router-dom'
import Layout from 'src/components/Layout'

import RegisterPage from './pages/Register'
import RegistrationPage from './pages/Registration'
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
    path: '/registration',
    element: (
      <Layout>
        <RegistrationPage />
      </Layout>
    ),
  },
  {
    path: '/registration/register',
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
