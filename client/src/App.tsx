import { createBrowserRouter, RouterProvider } from 'react-router-dom'
import Layout from 'src/components/Layout'

import SwapPage from './pages/Swap'

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
  return <RouterProvider router={router} />
}
