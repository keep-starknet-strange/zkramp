import EURLogo from 'src/assets/eur.png'
import USDCLogo from 'src/assets/usdc.png'

export type Currency = {
  img: string
  name: string
}

export enum FIAT_CURRENCY {
  EUR = 'EUR',
}

export enum TOKEN_CURRENCY {
  USDC = 'USDC',
}

export const FIAT_CURRENCIES = {
  [FIAT_CURRENCY.EUR]: {
    img: EURLogo,
    name: 'EUR',
  },
}

export const TOKEN_CURRENCIES = {
  [TOKEN_CURRENCY.USDC]: {
    img: USDCLogo,
    name: 'USDC',
  },
}
