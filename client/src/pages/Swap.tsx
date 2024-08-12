import { ChangeEvent, useState } from 'react'
import { PrimaryButton } from 'src/components/Button'
import { Card } from 'src/components/Card'
import { Column, Row } from 'src/components/Flex'
import { CurrencyInput } from 'src/components/Input'
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
  const [inputRequestValue, setInputRequestValue] = useState<string>('')
  const [inputSendValue, setInputSendValue] = useState<string>('')

  const handleRequestChange = (event: ChangeEvent<HTMLInputElement>) => {
    const inputValue = event.target.value
    const numericValue = inputValue.replace(/[^0-9]/g, '')
    setInputRequestValue(numericValue)
  }
  const handleSendChange = (event: ChangeEvent<HTMLInputElement>) => {
    const inputValue = event.target.value
    const numericValue = inputValue.replace(/[^0-9]/g, '')
    setInputSendValue(numericValue)
  }
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
            <CurrencyInput placeholder="0" value={inputRequestValue} onChange={handleRequestChange} />
            <ThemedText.HeadlineSmall>USDC</ThemedText.HeadlineSmall>
          </InputCardGroup>
        </Card>

        <Card gap={12} bg="surface">
          <InputCardGroup gap={16}>
            <ThemedText.BodyPrimary>You send</ThemedText.BodyPrimary>
          </InputCardGroup>

          <InputCardGroup gap={16}>
            <CurrencyInput placeholder="0" value={inputSendValue} onChange={handleSendChange} />
            <ThemedText.HeadlineSmall>USD</ThemedText.HeadlineSmall>
          </InputCardGroup>
        </Card>

        <PrimaryButton>
          <ThemedText.Title>Swap</ThemedText.Title>
        </PrimaryButton>
      </SwapCard>
    </Layout>
  )
}
