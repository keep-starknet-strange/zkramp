import { useAccount, useDisconnect } from '@starknet-react/core'
import { Link } from 'react-router-dom'
import { ThemedText } from 'src/theme/components'
import { DoubleChevronRight, Logout, StarknetLogo, UserCheck } from 'src/theme/components/icons'
import styled from 'styled-components'

import { Column, Row } from '../Flex'

const Container = styled(Column)`
  position: fixed;
  top: 0;
  right: 0;
  width: 372px;
  height: 100%;
  padding: 8px;
`

const Content = styled(Column)`
  width: 100%;
  height: 100%;
  padding: 16px;
  background-color: ${({ theme }) => theme.bg2};
  border: 1px solid ${({ theme }) => theme.border};
  border-radius: 20px;
`

const WalletInfo = styled(Row)`
  width: 100%;
  justify-content: space-between;
`

const CloseButton = styled.button`
  color: rgba(240, 247, 244, 0.5);
  background-color: transparent;
  border: none;
  cursor: pointer;
`

const Links = styled(Column)`
  width: 100%;
`

const LinkItem = styled(Row)`
  width: 100%;
  gap: 10px;
  padding: 12px 6px;
  background-color: transparent;
  border: none;
  border-radius: 8px;
  text-decoration: none;
  cursor: pointer;

  &:hover {
    background-color: ${({ theme }) => theme.bg3};
    box-shadow: 0px 1px 2px 0px rgba(0, 0, 0, 0.3), 0px 2px 6px 2px rgba(0, 0, 0, 0.15),
      0px 0.5px 0px 0px rgba(240, 247, 244, 0.1) inset;
  }

  div {
    color: ${({ theme }) => theme.neutral1};
  }
`

type WalletSidebarProps = {
  onClose?: () => void
}

export default function WalletSidebar({ onClose }: WalletSidebarProps) {
  const { address } = useAccount()
  const { disconnect } = useDisconnect()

  if (!address) return

  return (
    <Container>
      <Content gap={32}>
        <WalletInfo>
          <Row gap={12}>
            <StarknetLogo width={40} height={40} />
            <ThemedText.Title fontWeight={500}>
              {address.slice(0, 6)}...{address.slice(-4)}
            </ThemedText.Title>
          </Row>

          <CloseButton onClick={onClose}>
            <DoubleChevronRight width={24} height={24} />
          </CloseButton>
        </WalletInfo>

        <Links gap={16}>
          <LinkItem as={Link} to="/">
            <UserCheck width={28} height={28} color="#0047FF" />
            <ThemedText.BodyPrimary>Registration</ThemedText.BodyPrimary>
          </LinkItem>

          <LinkItem as="button" onClick={() => disconnect()}>
            <Logout width={28} height={28} color="#FF3442" />
            <ThemedText.BodyPrimary>Disconnect</ThemedText.BodyPrimary>
          </LinkItem>
        </Links>
      </Content>
    </Container>
  )
}
