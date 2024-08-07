import { Card } from 'src/components/Card'
import { Column, Row } from 'src/components/Flex'
import { ThemedText } from 'src/theme/components'
import { styled } from 'styled-components'

const Layout = styled(Column)`
  margin: 0 auto;
  justify-content: center;
  gap: 16px;
  height: 100vh;
`

const InputCardGroup = styled(Row)`
  width: 100%;
  justify-content: space-between;
`

const SwapCard = styled(Card)`
  width: 460px;
`

export default function SwapPage() {
  return (
    <Layout>
      <SwapCard gap={16} alignItems="flex-start">
        <ThemedText.HeadlineSmall>Swap</ThemedText.HeadlineSmall>

        <Card gap={12} bg="surface">
          <InputCardGroup gap={16}>
            <ThemedText.BodyPrimary>Requesting</ThemedText.BodyPrimary>
            <ThemedText.BodyPrimary>Balance: 0</ThemedText.BodyPrimary>
          </InputCardGroup>

          <InputCardGroup gap={16}>
            <input type="text" placeholder="0" style={{ flex: 1 }} />
            <ThemedText.HeadlineSmall>USDC</ThemedText.HeadlineSmall>
          </InputCardGroup>
        </Card>

        <Card gap={12} bg="surface">
          <InputCardGroup gap={16}>
            <ThemedText.BodyPrimary>You send</ThemedText.BodyPrimary>
          </InputCardGroup>

          <InputCardGroup gap={16}>
            <input type="text" placeholder="0" style={{ flex: 1 }} />
            <ThemedText.HeadlineSmall>USD</ThemedText.HeadlineSmall>
          </InputCardGroup>
        </Card>
      </SwapCard>
    </Layout>
  )
}
