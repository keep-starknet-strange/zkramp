import styled from 'styled-components'

export const PrimaryButton = styled.button`
  width: 100%;
  padding: 16px;
  background-color: ${({ theme }) => theme.accent1};
  border: 0;
  border-radius: 12px;
  font-weight: 500;
  cursor: pointer;

  &:disabled {
    background-color: ${({ theme }) => theme.surface};
    cursor: default;
  }
`

// eslint-disable-next-line import/no-unused-modules
export const OutlineButton = styled.button`
  border-radius: 12px;
  padding: 12px 24px;
  font-size: 16px;
  font-weight: 500;
  cursor: pointer;
  transition: all 0.2s ease;
  border: none;
  background: transparent;
  border: 1px solid ${({ theme }) => theme.white};
  color: ${({ theme }) => theme.white};
`
