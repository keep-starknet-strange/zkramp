import { useAccount } from '@starknet-react/core'
import { useState } from 'react'
import { NavLink } from 'react-router-dom'
import { ThemedText } from 'src/theme/components'
import { Logo } from 'src/theme/components/icons'
import styled from 'styled-components'

import { ConnectButton } from '../Button'
import { ConnectWalletModal } from '../ConnectWalletModal'
import { Row } from '../Flex'

const Container = styled(Row)`
  justify-content: space-between;
  padding: 24px 32px;
`

const Link = styled(ThemedText.BodyPrimary)`
  color: rgba(255, 255, 255, 0.7);
  font-weight: 500;
  font-size: 18px;
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
  border-radius: 99px;
`

const AccountStatusIcon = styled.div`
  width: 12px;
  height: 12px;
  background-color: ${({ theme }) => theme.green};
  border-radius: 12px;
`

export default function Header() {
  const [connectDropdownShown, setConnectDropdownShown] = useState(false)

  const { address } = useAccount()

  const toggleConnectDropdown = () => {
    setConnectDropdownShown((prev) => !prev)
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
        <AccountChip gap={4}>
          <AccountStatusIcon />

          <ThemedText.Title fontWeight={400}>
            {address.slice(0, 6)}...{address.slice(-4)}
          </ThemedText.Title>
        </AccountChip>
      ) : (
        <ConnectContainer>
          <ConnectButton onClick={toggleConnectDropdown}>Connect</ConnectButton>

          {connectDropdownShown && <ConnectWalletDropdown />}
        </ConnectContainer>
      )}
    </Container>
  )
}
