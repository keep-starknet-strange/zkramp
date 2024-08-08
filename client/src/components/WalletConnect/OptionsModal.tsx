import { useAccount, useConnect } from '@starknet-react/core'
import { useEffect } from 'react'
import { useWalletConnectModal } from 'src/hooks/useModal'
import { styled } from 'styled-components'

import { Column } from '../Flex'
import Content from '../Modal/Content'
import Overlay from '../Modal/Overlay'
import Portal from '../Portal'
import { L2Option } from './ConnectionOption'

export default function WalletConnectModal() {
  const [isOpen, toggle] = useWalletConnectModal()
  const { address: l2Account } = useAccount()
  const { connectors } = useConnect()

  useEffect(() => {
    if (l2Account) {
      toggle()
    }
  }, [toggle, l2Account])

  if (!isOpen) return null

  const FullWidthColumn = styled(Column)`
    width: 100%;
  `

  return (
    <Portal>
      <Overlay onClick={toggle} />
      <Content title="Connect wallet" close={toggle}>
        <FullWidthColumn gap={12}>
          {connectors
            .filter((connector) => connector.available())
            .map((connector) => (
              <L2Option key={connector.id} connection={connector} />
            ))}
        </FullWidthColumn>
      </Content>
    </Portal>
  )
}
