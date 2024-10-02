import { useCloseModal, useSelectAccountModal } from 'src/hooks/useModal'
import { ThemedText } from 'src/theme/components'
import { RevolutLogo, VenmoLogo } from 'src/theme/components/icons'
import styled from 'styled-components'

import { PrimaryButton } from '../Button'
import { Column, Row } from '../Flex'
import Content from '../Modal/Content'
import Overlay from '../Modal/Overlay'
import Portal from '../Portal'

const AccountButtons = styled(Column)`
  width: 100%;
`

const StyledAccountModal = styled(Row)`
  width: 100%;
  justify-content: space-between;
  padding: 16px;
  background-color: ${({ theme }) => theme.bg3};
  color: ${({ theme }) => theme.neutral1};
  border: none;
  border-radius: 12px;
  cursor: pointer;
`

interface AccountButtonProps extends React.ButtonHTMLAttributes<HTMLButtonElement> {
  Logo: React.FC<React.SVGProps<SVGSVGElement>>
  name: string
  currencies: string[]
}

const AccountButton = ({ Logo, name, currencies, ...props }: AccountButtonProps) => {
  return (
    <StyledAccountModal as="button" {...props}>
      <Row gap={16}>
        <Logo width={22} height={22} />

        <ThemedText.HeadlineSmall>{name}</ThemedText.HeadlineSmall>
      </Row>

      <ThemedText.BodySecondary>{currencies.join(', ')}</ThemedText.BodySecondary>
    </StyledAccountModal>
  )
}

export default function SelectAccountModal() {
  // modal
  const [isOpen] = useSelectAccountModal()
  const close = useCloseModal()

  if (!isOpen) return null

  return (
    <Portal>
      <Content title="Select account" close={close}>
        <AccountButtons gap={16}>
          <AccountButton Logo={RevolutLogo} name="Revolut" currencies={['EUR', 'USD']} />
          <AccountButton Logo={VenmoLogo} name="Venmo" currencies={['USD']} />
        </AccountButtons>

        <PrimaryButton>Register new account</PrimaryButton>
      </Content>

      <Overlay onClick={close} />
    </Portal>
  )
}
