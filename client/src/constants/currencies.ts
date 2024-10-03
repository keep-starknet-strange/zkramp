import EURLogo from 'src/assets/eur.png'
import USDCLogo from 'src/assets/usdc.png'

export type Currency = {
  img: string
  name: string
}

export const FIAT_CURRENCIES = {
  EUR: {
    img: EURLogo,
    name: 'EUR',
    symbol: '€',
  },
}

export const TOKEN_CURRENCIES = {
  USDC: {
    img: USDCLogo,
    name: 'USDC',
    symbol: 'USDC',
  },
}
