import { ChangeEvent, useState } from 'react'
import { PrimaryButton } from 'src/components/Button'
import { CurrencyButton } from 'src/components/CurrencyButton'
import { Column, Row } from 'src/components/Flex'
import { CurrencyInput } from 'src/components/Input'
import { FIAT_CURRENCIES, TOKEN_CURRENCIES } from 'src/constants/currencies'
import { ThemedText } from 'src/theme/components'
import { ArrowDown } from 'src/theme/components/icons'
import { styled } from 'styled-components'

const Content = styled(Column)`
  max-width: 460px;
  width: 100%;
  align-items: normal;
  gap: 24px;
  margin: 0 auto;
  margin-top: 120px;
`

const SwapCard = styled(Row)`
  width: 100%;
  background-color: ${({ theme }) => theme.bg3};
  border-radius: 12px;
  padding: 12px 16px;
`

const SwapCardContent = styled(Column)`
  flex: 1;
  align-items: flex-start;

  input {
    width: 100%;
    padding-top: 12px;
    padding-bottom: 24px;
    font-size: 42px;
    font-weight: 600;
    color: ${({ theme }) => theme.neutral1};

    &::placeholder {
      color: ${({ theme }) => theme.neutral2};
    }
  }
`

const SwitchButton = styled.button`
  display: flex;
  align-items: center;
  justify-content: center;
  color: ${({ theme }) => theme.neutral1};
  background-color: ${({ theme }) => theme.bg3};
  border: 4px solid ${({ theme }) => theme.bg1};
  border-radius: 6px;
  cursor: pointer;
  height: 32px;
  width: 32px;
  box-sizing: content-box;
  margin: -18px 0;
  z-index: 1;
  padding: 0;
`

export default function SwapPage() {
  const [rampMode, setRampMode] = useState<'on' | 'off'>('on')

  const [inputSendValue, setInputSendValue] = useState('')
  const [inputReceiveValue, setInputReceiveValue] = useState('')

  const handleReceiveChange = (event: ChangeEvent<HTMLInputElement>) => {
    const inputValue = event.target.value
    const numericValue = inputValue.replace(/[^0-9]/g, '')
    setInputReceiveValue(numericValue)
  }

  const handleSendChange = (event: ChangeEvent<HTMLInputElement>) => {
    const inputValue = event.target.value
    const numericValue = inputValue.replace(/[^0-9]/g, '')
    setInputSendValue(numericValue)
  }

  const handleChangeClick = () => {
    setRampMode((state) => (state == 'off' ? 'on' : 'off'))
    setInputSendValue(inputReceiveValue)
    setInputReceiveValue(inputSendValue)
  }

  return (
    <Content>
      <ThemedText.HeadlineLarge>Swap</ThemedText.HeadlineLarge>

      <Column gap={12}>
        <Column>
          <SwapCard as="label">
            <SwapCardContent>
              <ThemedText.Subtitle fontSize={12}>Send</ThemedText.Subtitle>
              <CurrencyInput placeholder="0.0" value={inputSendValue} onChange={handleSendChange} />
            </SwapCardContent>

            <CurrencyButton selectedCurrency={rampMode === 'on' ? FIAT_CURRENCIES['EUR'] : TOKEN_CURRENCIES['USDC']} />
          </SwapCard>

          <SwitchButton onClick={handleChangeClick}>
            <ArrowDown width={18} height={18} />
          </SwitchButton>

          <SwapCard as="label">
            <SwapCardContent>
              <ThemedText.Subtitle>Receive</ThemedText.Subtitle>
              <CurrencyInput placeholder="0.0" value={inputReceiveValue} onChange={handleReceiveChange} />
            </SwapCardContent>

            <CurrencyButton selectedCurrency={rampMode === 'off' ? FIAT_CURRENCIES['EUR'] : TOKEN_CURRENCIES['USDC']} />
          </SwapCard>
        </Column>

        <PrimaryButton>Swap</PrimaryButton>
      </Column>
    </Content>
  )
}
