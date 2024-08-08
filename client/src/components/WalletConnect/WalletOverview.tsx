import { useDisconnect, useNetwork } from '@starknet-react/core'
import { useCallback } from 'react'
import { useCloseModal, useWalletOverviewModal } from 'src/hooks/useModal'

import { OutlineButton } from '../Button'
import Content from '../Modal/Content'
import Overlay from '../Modal/Overlay'
import Portal from '../Portal'

interface ModalProps {
  chainLabel?: string
  disconnect: () => void
}

function OverviewModal({ chainLabel, disconnect }: ModalProps) {
  const close = useCloseModal()

  const disconnectAndClose = useCallback(() => {
    disconnect()
    close()
  }, [disconnect, close])

  return (
    <Portal>
      <Content title={`${chainLabel} wallet`} close={close}>
        <OutlineButton onClick={disconnectAndClose}>Disconnect</OutlineButton>
      </Content>

      <Overlay onClick={close} />
    </Portal>
  )
}

export function WalletOverview() {
  const [isOpen] = useWalletOverviewModal()
  const { disconnect } = useDisconnect()
  const { chain } = useNetwork()

  if (!isOpen) return null

  return <OverviewModal chainLabel={chain?.name} disconnect={disconnect} />
}
