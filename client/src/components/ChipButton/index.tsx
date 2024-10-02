import { ThemedText } from 'src/theme/components'
import styled from 'styled-components'

const StyledChipButton = styled(ThemedText.BodySecondary)<{ active?: boolean }>`
  background-color: ${({ theme }) => theme.bg3};
  color: ${({ theme, active }) => (active ? theme.neutral1 : theme.neutral2)};
  border: none;
  border-radius: 99px;
  padding: 8px 16px;
  cursor: pointer;
  transition: background-color 0.2s ease;

  &:hover {
    background-color: ${({ theme }) => theme.bg2};
  }
`

interface ChipButtonProps extends React.ButtonHTMLAttributes<HTMLButtonElement> {
  active?: boolean
}

export function ChipButton({ active, ...props }: ChipButtonProps) {
  return <StyledChipButton as="button" active={active} {...props} />
}
