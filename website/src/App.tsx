import { createBrowserRouter, RouterProvider } from 'react-router-dom'
import Layout from 'src/components/Layout'

import HomePage from './pages/Home'
import Swap from './pages/Swap'

const router = createBrowserRouter([
  {
    path: '/',
    element: (
      <Layout>
        <HomePage />
      </Layout>
    ),
  },
  {
    path: '/swap',
    element: (
      <Layout>
        <Swap />
      </Layout>
    ),
  },
])

export default function App() {
  return <RouterProvider router={router} />
}
