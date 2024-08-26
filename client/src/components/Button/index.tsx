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

export const ConnectButton = styled(PrimaryButton)`
  width: auto;
  padding: 14px 32px;
  background: linear-gradient(360deg, #202a31 0%, #28353e 100%);
  color: ${({ theme }) => theme.neutral1};
  font-size: 16px;
`
