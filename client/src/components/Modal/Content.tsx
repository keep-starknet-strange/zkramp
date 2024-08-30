import { ThemedText } from 'src/theme/components'
import * as Icons from 'src/theme/components/icons'
import { styled } from 'styled-components'

import { Column, Row } from '../Flex'

const StyledContent = styled.div`
  position: fixed;
  z-index: 1060;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
  display: flex;
  flex-direction: column;
  justify-content: center;
  width: 100%;
  max-width: 480px;
  padding: 16px;
  background: ${({ theme }) => theme.bg2};
  border: 1px solid ${({ theme }) => theme.border};
  border-radius: 20px;
`

const TitleContainer = styled(Row)`
  width: 100%;
`

const Title = styled(ThemedText.HeadlineSmall)`
  width: 100%;
  text-overflow: ellipsis;
  white-space: nowrap;
  overflow: hidden;
`

const CloseContainer = styled.button`
  width: 28px;
  height: 28px;
  padding: 4px;
  background: transparent;
  color: ${({ theme }) => theme.neutral1};
  border: none;
  cursor: pointer;
  transition: color 0.15s linear;

  & > svg {
    display: block;
  }

  &:hover {
    color: ${({ theme }) => theme.neutral2};
  }
`

interface ContentProps {
  children: React.ReactNode
  title: string
  close?: () => void
}

export default function Content({ children, title, close }: ContentProps) {
  return (
    <StyledContent>
      <Column gap={32}>
        <TitleContainer>
          <Title>{title}</Title>

          {close && (
            <CloseContainer onClick={close}>
              <Icons.Close />
            </CloseContainer>
          )}
        </TitleContainer>

        {children}
      </Column>
    </StyledContent>
  )
}
