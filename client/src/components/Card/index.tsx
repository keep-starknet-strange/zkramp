import styled from 'styled-components'

import { Column } from '../Flex'

// eslint-disable-next-line import/no-unused-modules
export const Card = styled(Column)<{ bg?: string }>`
  width: 100%;
  padding: 12px;
  background-color: ${({ bg = 'bg2', theme }) => theme[bg]};
  border: 1px solid ${({ theme }) => theme.border};
  border-radius: 6px;
`
