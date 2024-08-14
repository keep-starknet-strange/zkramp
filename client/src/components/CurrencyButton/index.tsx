import { ThemedText } from 'src/theme/components'
import { ChevronDown } from 'src/theme/components/icons'
import styled from 'styled-components'

import { Row } from '../Flex'

const CurrencyCard = styled(Row)`
  background-color: ${({ theme }) => theme.bg2};
  color: ${({ theme }) => theme.neutral1};
  padding: ${({ theme }) => theme.grids.xs};
  padding-right: ${({ theme }) => theme.grids.sm};
  border: 1px solid ${({ theme }) => theme.border};
  border-radius: 99px;

  img {
    width: 28px;
    height: 28px;
    border-radius: 28px;
  }
`

type Currency = {
  img: string
  name: string
}

type CurrencyButtonProps<
  TSymbols extends string,
  TCurrency extends Currency,
  TAvailableCurrencies extends Record<TSymbols, TCurrency>
> = {
  selectedCurrency: keyof TAvailableCurrencies
  availableCurrencies: TAvailableCurrencies
}

export const CurrencyButton = <
  TSymbols extends string,
  TCurrency extends Currency,
  TAvailableCurrencies extends Record<TSymbols, TCurrency>
>(
  props: CurrencyButtonProps<TSymbols, TCurrency, TAvailableCurrencies>
) => {
  const { selectedCurrency, availableCurrencies } = props

  const currency = availableCurrencies[selectedCurrency]

  return (
    <CurrencyCard as="button" gap={4}>
      <img src={currency.img} alt={currency.name} />

      <ThemedText.Title fontWeight={500}>{currency.name}</ThemedText.Title>

      <ChevronDown width={18} height={18} />
    </CurrencyCard>
  )
}
