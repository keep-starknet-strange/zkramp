import { Currency } from 'src/constants/currencies'
import { ThemedText } from 'src/theme/components'
import styled from 'styled-components'

import { Row } from '../Flex'

const CurrencyCard = styled(Row)`
  background-color: ${({ theme }) => theme.bg2};
  color: ${({ theme }) => theme.neutral1};
  padding: 4px 8px 4px 4px;
  border: 1px solid ${({ theme }) => theme.border};
  border-radius: 99px;

  img {
    width: 28px;
    height: 28px;
    border-radius: 28px;
    object-fit: cover;
  }
`

interface CurrencyButtonProps {
  selectedCurrency: Currency
}

export function CurrencyButton({ selectedCurrency }: CurrencyButtonProps) {
  return (
    <CurrencyCard as="button" gap={4}>
      <img src={selectedCurrency.img} alt={selectedCurrency.name} />

      <ThemedText.BodyPrimary fontWeight={500}>{selectedCurrency.name}</ThemedText.BodyPrimary>
    </CurrencyCard>
  )
}
