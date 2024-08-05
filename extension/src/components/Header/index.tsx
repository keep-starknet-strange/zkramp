import { ThemedText } from 'src/theme/components'
import * as Icons from 'src/theme/components/icons'
import { styled } from 'styled-components'

import { Row } from '../Flex'

const StyledHeader = styled(Row)`
  height: 64px;
  padding: 0 20px;
  gap: 16px;
`

export default function Header() {
  return (
    <StyledHeader>
      <Icons.Logo width={32} />
      <ThemedText.BodyPrimary>zkRamp</ThemedText.BodyPrimary>
    </StyledHeader>
  )
}
