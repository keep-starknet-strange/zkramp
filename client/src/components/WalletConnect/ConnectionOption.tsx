import { Connector, useConnect } from '@starknet-react/core'

import { Row } from '../Flex'

interface OptionProps {
  connection: Connector
  activate: () => void
}

function Option({ connection, activate }: OptionProps) {
  const icon = connection.icon.dark
  const isSvg = icon?.startsWith('<svg')

  return (
    <Row gap={12} onClick={activate}>
      {isSvg ? (
        <img width="32" height="32" dangerouslySetInnerHTML={{ __html: icon ?? '' }} /> /* display svg */
      ) : (
        <img width="32" height="32" src={connection.icon.dark} />
      )}
      <p>{connection.name}</p>
    </Row>
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
