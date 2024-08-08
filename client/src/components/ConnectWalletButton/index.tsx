import { useAccount } from '@starknet-react/core'
import { useWalletConnectModal, useWalletOverviewModal } from 'src/hooks/useModal'
import * as Icons from 'src/theme/components/icons'
import { shortenL2Address } from 'src/utils/address'
import styled from 'styled-components'

import { OutlineButton } from '../Button'
import { Row } from '../Flex'

interface ConnectButtonProps {
  label: string
  backgroundColor: string
  textColor: string
}

const StyledButton = styled(OutlineButton)<ConnectButtonProps>`
  background: ${({ backgroundColor }) => backgroundColor};
  color: ${({ textColor }) => textColor};
`

export default function ConnectWalletButton({ label, backgroundColor, textColor }: ConnectButtonProps) {
  const { address: l2Account } = useAccount()
  const [, toggleWalletConnectModal] = useWalletConnectModal()
  const [, toggleWalletOverviewModal] = useWalletOverviewModal()

  if (l2Account) {
    return (
      <Row gap={8}>
        <OutlineButton onClick={toggleWalletOverviewModal}>
          <Row gap={8}>
            <Icons.Starknet height={18} width={18} />
            {shortenL2Address(l2Account)}
          </Row>
        </OutlineButton>
      </Row>
    )
  } else {
    return (
      <StyledButton
        label={label}
        backgroundColor={backgroundColor}
        textColor={textColor}
        onClick={toggleWalletConnectModal}
      >
        {label}
      </StyledButton>
    )
  }
}
