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

export default function Swap() {
  return (
    <Layout>
      <SwapCard gap={16} alignItems="flex-start">
        <ThemedText.SubHeader>Swap</ThemedText.SubHeader>

        <Card gap={12} bg="surface">
          <InputCardGroup gap={16}>
            <ThemedText.Normal>Requesting</ThemedText.Normal>
            <ThemedText.Normal>Balance: 0</ThemedText.Normal>
          </InputCardGroup>

          <InputCardGroup gap={16}>
            <input type="text" placeholder="0" style={{ flex: 1 }} />
            <ThemedText.SubHeader>USDC</ThemedText.SubHeader>
          </InputCardGroup>
        </Card>

        <Card gap={12} bg="surface">
          <InputCardGroup gap={16}>
            <ThemedText.Normal>You send</ThemedText.Normal>
          </InputCardGroup>

          <InputCardGroup gap={16}>
            <input type="text" placeholder="0" style={{ flex: 1 }} />
            <ThemedText.SubHeader>USD</ThemedText.SubHeader>
          </InputCardGroup>
        </Card>
      </SwapCard>
    </Layout>
  )
}
