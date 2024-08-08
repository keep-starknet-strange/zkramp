import { Connector, useConnect } from '@starknet-react/core'
import { styled } from 'styled-components'

import { Row } from '../Flex'

interface OptionProps {
  connection: Connector
  activate: () => void
}

const OptionRow = styled(Row)`
  width: 100%;
  cursor: pointer;
  padding: 12px;
  border-radius: 10px;
  &:hover {
    background-color: ${({ theme }) => theme.white};
    color: ${({ theme }) => theme.black};
  }
`

function Option({ connection, activate }: OptionProps) {
  const icon = connection.icon.dark
  const isSvg = icon?.startsWith('<svg')

  return (
    <OptionRow gap={12} onClick={activate}>
      {isSvg ? (
        <img width="32" height="32" dangerouslySetInnerHTML={{ __html: icon ?? '' }} /> /* display svg */
      ) : (
        <img width="32" height="32" src={connection.icon.dark} />
      )}
      <p style={{ margin: '0' }}>{connection.name}</p>
    </OptionRow>
  )
}

interface L2OptionProps {
  connection: Connector
}

export function L2Option({ connection }: L2OptionProps) {
  // wallet activation
  const { connect } = useConnect()
  const activate = () => connect({ connector: connection })

  return <Option connection={connection} activate={activate} />
}
