import { ChangeEvent, useState } from 'react'
import { PrimaryButton } from 'src/components/Button'
import { CurrencyButton } from 'src/components/CurrencyButton'
import { Column, Row } from 'src/components/Flex'
import { CurrencyInput } from 'src/components/Input'
import { ThemedText } from 'src/theme/components'
import { ArrowDown } from 'src/theme/components/icons'
import { styled } from 'styled-components'

import EURLogo from '../assets/eur.png'
import RevolutLogo from '../assets/revolut.png'
import USDCLogo from '../assets/usdc.png'

const Layout = styled(Column)`
  margin: 0 auto;
  justify-content: center;
  height: 100vh;
`

const Content = styled(Column)`
  max-width: 460px;
  width: 100%;
`

const Headline = styled(Row)`
  width: 100%;
  justify-content: space-between;
  margin-bottom: ${({ theme }) => theme.grids.md};
`

const PlatformCard = styled(Row)`
  border: 1px solid ${({ theme }) => theme.border};
  border-radius: 12px;

  img {
    width: 48px;
    height: 48px;
    border-radius: 12px;
  }

  > div {
    padding: ${({ theme }) => theme.grids.sm} ${({ theme }) => theme.grids.md};
  }
`

const SwapCards = styled(Column)`
  position: relative;
  width: 100%;
`

const SwapCard = styled(Row)`
  width: 100%;
  background-color: ${({ theme }) => theme.bg3};
  border-radius: 12px;
  padding: ${({ theme }) => theme.grids.md} 16px;
`

const SwapCardContent = styled(Column)`
  flex: 1;
  align-items: flex-start;

  input {
    width: 100%;
    padding-top: ${({ theme }) => theme.grids.md};
    padding-bottom: ${({ theme }) => theme.grids.lg};
    font-size: 42px;
    font-weight: 600;
    color: ${({ theme }) => theme.neutral1};

    &::placeholder {
      color: ${({ theme }) => theme.neutral2};
    }
  }
`

const ChangeButton = styled.button`
  position: absolute;
  top: 50%;
  left: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  color: ${({ theme }) => theme.neutral1};
  transform: translateX(-50%) translateY(-50%);
  background-color: ${({ theme }) => theme.bg3};
  border: 4px solid ${({ theme }) => theme.bg2};
  border-radius: 6px;
  padding: 6px;
  cursor: pointer;
`

export default function SwapPage() {
  const [inputRequestValue, setInputRequestValue] = useState('')
  const [inputSendValue, setInputSendValue] = useState('')

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
      <Content gap={12}>
        <Headline>
          <ThemedText.HeadlineLarge>Swap</ThemedText.HeadlineLarge>

          <PlatformCard>
            <img src={RevolutLogo} alt="Revolut" />

            <Column alignItems="flex-start">
              <ThemedText.Title fontWeight={400}>Revolut</ThemedText.Title>
              <ThemedText.BodyPrimary fontSize={12}>Platform</ThemedText.BodyPrimary>
            </Column>
          </PlatformCard>
        </Headline>

        <SwapCards gap={4}>
          <SwapCard as="label">
            <SwapCardContent>
              <ThemedText.BodyPrimary fontSize={12}>Send</ThemedText.BodyPrimary>
              <CurrencyInput placeholder="0.0" value={inputSendValue} onChange={handleSendChange} />
            </SwapCardContent>

            <CurrencyButton availableCurrencies={{ EUR: { img: EURLogo, name: 'EUR' } }} selectedCurrency="EUR" />
          </SwapCard>

          <SwapCard as="label">
            <SwapCardContent>
              <ThemedText.BodyPrimary fontSize={12}>Receive</ThemedText.BodyPrimary>
              <CurrencyInput placeholder="0.0" value={inputRequestValue} onChange={handleRequestChange} />
            </SwapCardContent>

            <CurrencyButton availableCurrencies={{ USDC: { img: USDCLogo, name: 'USDC' } }} selectedCurrency="USDC" />
          </SwapCard>

          <ChangeButton>
            <ArrowDown width={18} height={18} />
          </ChangeButton>
        </SwapCards>

        <PrimaryButton>
          <ThemedText.Title>Swap</ThemedText.Title>
        </PrimaryButton>
      </Content>
    </Layout>
  )
}
