import { Column, Row } from 'src/components/Flex'
import { ThemedText } from 'src/theme/components'
import * as Icons from 'src/theme/components/icons'
import { styled } from 'styled-components'

const ComingSoon = styled(Column)`
  width: 300px;
  margin: 0 auto;
  justify-content: center;
  gap: 16px;
  height: 80vh;
`

export default function HomePage() {
  return (
    <ComingSoon>
      <Row gap={16}>
        <Icons.Logo height="100px" />
        <ThemedText.HeadlineLarge>zkRamp</ThemedText.HeadlineLarge>
      </Row>

      <ThemedText.SubHeader>Coming soon</ThemedText.SubHeader>
    </ComingSoon>
  )
}
