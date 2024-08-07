import { goerli, mainnet } from '@starknet-react/chains'
import { argent, braavos, publicProvider, StarknetConfig, useInjectedConnectors } from '@starknet-react/core'

// eslint-disable-next-line import/no-unused-modules
export default function StarknetProvider({ children }: React.HTMLAttributes<HTMLDivElement>) {
  const chains = [goerli, mainnet]
  const provider = publicProvider()
  const { connectors } = useInjectedConnectors({
    recommended: [argent(), braavos()],
    includeRecommended: 'onlyIfNoConnectors',
    order: 'random',
  })

  return (
    <StarknetConfig chains={chains} provider={provider} connectors={connectors}>
      {children}
    </StarknetConfig>
  )
}
