import { useAccount } from '@starknet-react/core'
import { useState } from 'react'
import { NavLink } from 'react-router-dom'
import { ThemedText } from 'src/theme/components'
import { Logo } from 'src/theme/components/icons'
import styled from 'styled-components'

import { ConnectButton } from '../Button'
import { ConnectWalletModal } from '../ConnectWalletModal'
import { Row } from '../Flex'
import WalletSidebar from '../WalletSidebar'

const Container = styled(Row)`
  justify-content: space-between;
  padding: 24px 32px;
`

const Link = styled(ThemedText.BodyPrimary)`
  color: rgba(255, 255, 255, 0.7);
  text-decoration: none;

  &.active {
    color: ${({ theme }) => theme.neutral1};
  }
`

const ConnectContainer = styled(Row)`
  position: relative;
`

const ConnectWalletDropdown = styled(ConnectWalletModal)`
  position: absolute;
  top: calc(100% + 16px);
  right: 0;
`

const AccountChip = styled(Row)`
  padding: 6px 8px;
  background-color: ${({ theme }) => theme.bg3};
  border: none;
  border-radius: 99px;
  cursor: pointer;
`

const AccountStatusIcon = styled.div`
  width: 12px;
  height: 12px;
  background-color: ${({ theme }) => theme.green};
  border-radius: 12px;
`

export default function Header() {
  const [connectDropdownShown, setConnectDropdownShown] = useState(false)
  const [walletSidebarShown, setWalletSidebarShown] = useState(false)

  const { address } = useAccount()

  const toggleConnectDropdown = () => {
    setConnectDropdownShown((prev) => !prev)
  }

  const showWalletSidebar = () => {
    setWalletSidebarShown(true)
  }
  const hideWalletSidebar = () => {
    setWalletSidebarShown(false)
  }

  return (
    <Container as="header">
      <Row gap={32}>
        <Logo width={42} height={42} />

        <Row gap={28}>
          <Link as={NavLink} to="/">
            Swap
          </Link>

          <Link as={NavLink} to="/liquidity">
            Liquidity
          </Link>
        </Row>
      </Row>

      {address ? (
        <AccountChip as="button" gap={4} onClick={showWalletSidebar}>
          <AccountStatusIcon />

          <ThemedText.BodyPrimary>
            {address.slice(0, 6)}...{address.slice(-4)}
          </ThemedText.BodyPrimary>
        </AccountChip>
      ) : (
        <ConnectContainer>
          <ConnectButton onClick={toggleConnectDropdown}>Connect</ConnectButton>

          {connectDropdownShown && <ConnectWalletDropdown />}
        </ConnectContainer>
      )}

      {walletSidebarShown && <WalletSidebar onClose={hideWalletSidebar} />}
    </Container>
  )
}
