// Based mostly on https://github.com/Uniswap/interface/blob/main/src/theme/index.tsx

const colors = {
  white: '#FFFFFF',
  black: '#000000',

  neutral1_dark: '#ffffff',
  neutral2_dark: 'rgba(240, 247, 244, 0.5)',
}

const commonTheme = {
  white: colors.white,
  black: colors.black,

  accent1: '#FF3864',
}

export const darkTheme = {
  ...commonTheme,

  bg1: '#000000',
  bg2: '#121216',
  bg3: '#181F25',

  surface: '#0D0D12',

  border: 'rgba(240, 247, 244, 0.1)',

  neutral1: colors.neutral1_dark,
  neutral2: colors.neutral2_dark,
}
