/**
 * Preset styles of the Rebass Text component
 */

import { Text, TextProps as TextPropsOriginal } from 'rebass'
import styled from 'styled-components'

type FontFamily = 'Montserrat' | 'Inter'

interface TextWrapperCustomProps {
  color: keyof string
  fontFamily: FontFamily
}

const TextWrapper = styled(Text).withConfig({
  shouldForwardProp: (prop) => prop !== 'color' && prop !== 'fontFamily',
})<TextWrapperCustomProps>`
  color: ${({ color, theme }) => (theme as any)[color]};
  ${({ fontFamily }) => (fontFamily ? `font-family: '${fontFamily}';` : '')}
`

type TextProps = Omit<TextPropsOriginal, 'css'>

// todo: export each component individually
export const ThemedText = {
  Custom(props: TextProps) {
    return <TextWrapper {...props} />
  },

  HeadlineLarge(props: TextProps) {
    return <TextWrapper fontWeight={500} fontSize={36} color="neutral1" fontFamily="Montserrat" {...props} />
  },

  HeadlineSmall(props: TextProps) {
    return <TextWrapper fontWeight={500} fontSize={20} color="neutral1" fontFamily="Montserrat" {...props} />
  },

  BodyPrimary(props: TextProps) {
    return <TextWrapper fontWeight={400} fontSize={16} color="neutral1" fontFamily="Montserrat" {...props} />
  },

  BodySecondary(props: TextProps) {
    return <TextWrapper fontWeight={400} fontSize={14} color="neutral2" fontFamily="Montserrat" {...props} />
  },

  Title(props: TextProps) {
    return <TextWrapper fontWeight={600} fontSize={16} color="neutral1" fontFamily="Montserrat" {...props} />
  },
}
