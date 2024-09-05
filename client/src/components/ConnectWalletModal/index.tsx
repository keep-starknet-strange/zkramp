import { useConnect } from '@starknet-react/core'
import { ThemedText } from 'src/theme/components'
import styled from 'styled-components'

import { Column, Row } from '../Flex'

const Container = styled(Column)`
  width: 300px;
  align-items: flex-start;
  padding: 16px;
  background-color: ${({ theme }) => theme.bg2};
  border: 1px solid ${({ theme }) => theme.border};
  border-radius: 20px;
  box-shadow: 0px 4px 4px 4px rgba(0, 0, 0, 0.3), 0px 8px 12px 10px rgba(0, 0, 0, 0.15);
`

const ConnectorsList = styled(Column)`
  width: 100%;

  :first-child {
    border-top-left-radius: 12px;
    border-top-right-radius: 12px;
  }

  :last-child {
    border-bottom-left-radius: 12px;
    border-bottom-right-radius: 12px;
  }
`

const ConnectorCard = styled(Row)`
  width: 100%;
  padding: 12px;
  background-color: ${({ theme }) => theme.bg3};
  border: none;
  outline: none;
  cursor: pointer;

  img {
    width: 32px;
    height: 32px;
  }
`

export const ConnectWalletModal = (props: React.ComponentPropsWithoutRef<typeof Container>) => {
  const { connect, connectors } = useConnect()

  return (
    <Container gap={16} {...props}>
      <ThemedText.HeadlineSmall fontWeight={400}>Connect wallet</ThemedText.HeadlineSmall>

      <ConnectorsList gap={4}>
        {connectors
          .filter((connector) => connector.available())
          .map((connector) => (
            <ConnectorCard as="button" key={connector.id} gap={16} onClick={() => connect({ connector })}>
              <img src={connector.icon.dark} alt={connector.name} width={32} height={32} />

              <ThemedText.BodyPrimary>{connector.name}</ThemedText.BodyPrimary>
            </ConnectorCard>
          ))}
      </ConnectorsList>
    </Container>
  )
}
