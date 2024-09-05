import React, { useMemo } from 'react'
import { createGlobalStyle, ThemeProvider as StyledComponentsThemeProvider } from 'styled-components'

import { darkTheme } from './colors'

const MAX_CONTENT_WIDTH = '1180px'
const HEADER_HEIGHT = '114px'

const BREAKPOINTS = {
  xs: 480,
  sm: 640,
  md: 768,
  lg: 1024,
  xl: 1280,
  xxl: 1536,
  xxxl: 1920,
}

// deprecated - please use the ones in styles.ts file
const transitions = {
  duration: {
    slow: '500ms',
    medium: '250ms',
    fast: '125ms',
  },
  timing: {
    ease: 'ease',
    in: 'ease-in',
    out: 'ease-out',
    inOut: 'ease-in-out',
  },
}

const opacities = {
  hover: 0.6,
  click: 0.4,
  disabled: 0.5,
  enabled: 1,
}

const fonts = {
  code: 'courier, courier new, serif',
}

function getSettings() {
  return {
    fonts,

    // shadows
    shadow1: '#000',

    mobileBottomBarHeight: 48,
    maxWidth: MAX_CONTENT_WIDTH,
    headerHeight: HEADER_HEIGHT,

    // deprecated - please use hardcoded exported values instead of
    // adding to the theme object
    breakpoint: BREAKPOINTS,
    transition: transitions,
    opacity: opacities,
  }
}

export function getTheme() {
  return {
    ...darkTheme,
    ...getSettings(),
  }
}

export default function ThemeProvider({ children }: { children: React.ReactNode }) {
  const themeObject = useMemo(() => getTheme(), [])

  return <StyledComponentsThemeProvider theme={themeObject}>{children}</StyledComponentsThemeProvider>
}

export const ThemedGlobalStyle = createGlobalStyle`
  html {
    color: ${({ theme }) => theme.neutral1};
    background-color: ${({ theme }) => theme.bg1} !important;
  }

  body {
    margin: 0;
    padding: 0;
  }

  html, body, #root {
    height: 100%;
  }

  #root {
    display: flex;
    flex-direction: column;
  }

  * {
    box-sizing: border-box;
    font-family: 'Inter';
  }

  summary::-webkit-details-marker {
    display:none;
  }
`
