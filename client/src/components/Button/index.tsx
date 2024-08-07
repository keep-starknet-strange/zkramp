import styled from 'styled-components'

export const PrimaryButton = styled.button`
  width: 100%;
  padding: ${({ theme }) => theme.grids.md};
  background-color: ${({ theme }) => theme.accent1};
  border: 0;
  border-radius: 6px;
  cursor: pointer;

  &:disabled {
    background-color: ${({ theme }) => theme.surface};
    cursor: default;
  }
`
