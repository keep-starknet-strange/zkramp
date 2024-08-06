import { goerli, mainnet } from '@starknet-react/chains'
import { argent, braavos, publicProvider, StarknetConfig, useInjectedConnectors } from '@starknet-react/core'
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
  const chains = [goerli, mainnet]
  const provider = publicProvider()
  const { connectors } = useInjectedConnectors({
    recommended: [argent(), braavos()],
    includeRecommended: 'onlyIfNoConnectors',
    order: 'random',
  })

  return (
    <StarknetConfig chains={chains} provider={provider} connectors={connectors}>
      <RouterProvider router={router} />
    </StarknetConfig>
  )
}
