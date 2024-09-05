import { useCloseModal, useProofGenerationModal } from 'src/hooks/useModal'
import { ThemedText } from 'src/theme/components'
import { Logo } from 'src/theme/components/icons'

import { Column } from '../Flex'
import Content from '../Modal/Content'
import Overlay from '../Modal/Overlay'
import Portal from '../Portal'

export default function GenerateProofModal() {
  // modal
  const [isOpen] = useProofGenerationModal()
  const close = useCloseModal()

  if (!isOpen) return null

  return (
    <Portal>
      <Content title="Proof generation" close={close}>
        <Column gap={42} alignItems="center">
          <Column gap={16}>
            <Logo width={42} height={42} />

            <ThemedText.HeadlineSmall>Snarkification of the elliptic curve...</ThemedText.HeadlineSmall>
          </Column>

          <ThemedText.BodySecondary fontSize={16}>This might take a while</ThemedText.BodySecondary>
        </Column>
      </Content>

      <Overlay onClick={close} />
    </Portal>
  )
}
