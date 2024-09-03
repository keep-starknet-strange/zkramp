// Based mostly on https://github.com/Uniswap/interface/blob/main/src/theme/index.tsx

const colors = {
  white: '#FFFFFF',
  black: '#000000',
  green: '#21C95E',

  neutral1_dark: '#ffffff',
  neutral2_dark: 'rgba(240, 247, 244, 0.5)',
}

const commonTheme = {
  white: colors.white,
  black: colors.black,
  green: colors.green,

  accent1: '#FF3864',
}

export const darkTheme = {
  ...commonTheme,

  bg1: '#000000',
  bg2: '#101519',
  bg3: '#181F25',

  surface: '#0D0D12',

  border: 'rgba(240, 247, 244, 0.1)',
  border2: 'rgba(240, 247, 244, 0.5)',

  neutral1: colors.neutral1_dark,
  neutral2: colors.neutral2_dark,
}
