import { ChangeEvent, useState } from 'react'
import { PrimaryButton } from 'src/components/Button'
import { ChipButton } from 'src/components/ChipButton'
import { CurrencyButton } from 'src/components/CurrencyButton'
import { Column, Row } from 'src/components/Flex'
import { CurrencyInput } from 'src/components/Input'
import { FIAT_CURRENCIES, TOKEN_CURRENCIES } from 'src/constants/currencies'
import { ThemedText } from 'src/theme/components'
import { ChevronDown } from 'src/theme/components/icons'
import { styled } from 'styled-components'

const Content = styled(Column)`
  max-width: 460px;
  width: 100%;
  align-items: normal;
  margin: 0 auto;
  margin-top: 120px;
`

const SwapCard = styled(Column)`
  width: 100%;
  padding: 12px 16px;
  background-color: ${({ theme }) => theme.bg3};
  border-top-left-radius: 12px;
  border-top-right-radius: 12px;
`

const FiatCurrenyCard = styled(Row)`
  width: 100%;
  justify-content: space-between;
`

const SwapCardContent = styled(Column)`
  flex: 1;
  width: 100%;
  padding: 34px 0 42px 0;
`

const TokenCurrencyButton = styled(CurrencyButton)`
  gap: 8px;
  background-color: transparent;
  border: none;
  margin: 8px 0 12px 0;

  img {
    width: 18px;
    height: 18px;
  }
`

const PresetAmountButton = styled(ChipButton)`
  background-color: ${({ theme }) => theme.bg1};
  color: ${({ theme }) => theme.neutral1};
  border: 1px solid ${({ theme }) => theme.border};
  padding: 6px 12px;
`

const RampCard = styled(Row)`
  justify-content: space-between;
  width: 100%;
  padding: 12px 16px;
  background-color: ${({ theme }) => theme.bg3};
  border-bottom-left-radius: 12px;
  border-bottom-right-radius: 12px;
`

const AccountButton = styled(PrimaryButton)`
  width: auto;
  align-items: center;
  gap: 4px;
  padding: 8px;
`

export default function SwapPage() {
  const [rampMode, setRampMode] = useState<'on' | 'off'>('on')
  const [fiatCurrency, setFiatCurrency] = useState(FIAT_CURRENCIES['EUR'])
  const [tokenCurrency, setTokenCurrency] = useState(TOKEN_CURRENCIES['USDC'])

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

  return (
    <Content gap={24}>
      <Row gap={16}>
        <ChipButton active>Buy</ChipButton>
        <ChipButton>Sell</ChipButton>
      </Row>

      <Column gap={12}>
        <Column gap={2}>
          <SwapCard as="label">
            <FiatCurrenyCard>
              <ThemedText.Subtitle fontSize={14} color="neutral1">
                You&apos;re buying
              </ThemedText.Subtitle>

              <CurrencyButton selectedCurrency={fiatCurrency} />
            </FiatCurrenyCard>

            <SwapCardContent>
              <CurrencyInput
                placeholder={`0${fiatCurrency.symbol}`}
                value={inputSendValue}
                onChange={handleSendChange}
              />

              <TokenCurrencyButton selectedCurrency={tokenCurrency} />

              <Row gap={8}>
                <PresetAmountButton>100{fiatCurrency.symbol}</PresetAmountButton>
                <PresetAmountButton>300{fiatCurrency.symbol}</PresetAmountButton>
                <PresetAmountButton>1000{fiatCurrency.symbol}</PresetAmountButton>
              </Row>
            </SwapCardContent>
          </SwapCard>

          <RampCard>
            <ThemedText.BodyPrimary>From</ThemedText.BodyPrimary>

            <AccountButton>
              <span>Select account</span>
              <ChevronDown width={14} height={14} />
            </AccountButton>
          </RampCard>
        </Column>

        <PrimaryButton disabled>Enter amount</PrimaryButton>
      </Column>
    </Content>
  )
}
