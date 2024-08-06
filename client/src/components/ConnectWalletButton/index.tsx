import { useWalletConnectModal } from 'src/hooks/useModal'
import styled from 'styled-components'

interface ConnectButtonProps {
  label: string
  backgroundColor: string
  textColor: string
}

const StyledButton = styled.button<ConnectButtonProps>`
  background: ${({ backgroundColor }) => backgroundColor};
  color: ${({ textColor }) => textColor};
  border-radius: 12px;
  padding: 12px 24px;
  font-size: 16px;
  font-weight: 500;
  cursor: pointer;
  transition: all 0.2s ease;
  border: none;
`

export default function ConnectWalletButton({ label, backgroundColor, textColor }: ConnectButtonProps) {
  const [, toggleWalletConnectModal] = useWalletConnectModal()
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
