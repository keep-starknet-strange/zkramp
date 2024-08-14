import { NavLink } from 'react-router-dom'
import { ThemedText } from 'src/theme/components'
import { Logo } from 'src/theme/components/icons'
import styled from 'styled-components'

import { ConnectButton } from '../Button'
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

export default function Header() {
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

      <Row>
        <ConnectButton>Connect</ConnectButton>
      </Row>
    </Container>
  )
}
