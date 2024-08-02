import { ThemedText } from 'src/theme/components'
import * as Icons from 'src/theme/components/icons'
import { styled } from 'styled-components'

import { Column, Row } from '../Flex'

const StyledContent = styled.div`
  border: 3px solid ${({ theme }) => theme.neutral1};
  padding: 80px 32px;
  background: ${({ theme }) => theme.bg1};
  z-index: 1060;
  position: fixed;
  width: 100%;
  top: 0;
  bottom: 0;
  display: flex;
  flex-direction: column;
  justify-content: center;

  @media only screen and (min-width: ${({ theme }) => `${theme.breakpoint.xs}px`}) {
    left: 50%;
    top: 50%;
    width: 386px;
    transform: translate(-50%, -50%);
    padding: 32px;
    bottom: unset;
  }
`

const TitleContainer = styled(Row)`
  position: absolute;
  width: 100%;
  padding: 0 4px;
  text-align: center;
  top: 16px;

  & > div {
    text-overflow: ellipsis;
    white-space: nowrap;
    overflow: hidden;
    width: 100%;
  }

  @media only screen and (min-width: ${({ theme }) => `${theme.breakpoint.xs}px`}) {
    top: -32px;
    text-align: left;
  }
`

const CloseContainer = styled.div`
  position: absolute;
  color: ${({ theme }) => theme.neutral1};
  width: 28px;
  height: 28px;
  padding: 4px;
  cursor: pointer;
  border: 3px solid ${({ theme }) => theme.neutral1};
  top: -3px;
  right: -3px;

  & > svg {
    display: block;
  }

  &:hover {
    background: ${({ theme }) => theme.neutral1};
    color: ${({ theme }) => theme.bg1};
  }
`

interface ContentProps {
  children: React.ReactNode
  title: string
  close: () => void
}

export default function Content({ children, title, close }: ContentProps) {
  return (
    <StyledContent>
      <Column gap={32}>
        <TitleContainer>
          <ThemedText.HeadlineSmall>{title}</ThemedText.HeadlineSmall>
        </TitleContainer>

        <CloseContainer onClick={close}>
          <Icons.Close />
        </CloseContainer>

        {children}
      </Column>
    </StyledContent>
  )
}
