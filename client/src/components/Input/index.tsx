import React, { ChangeEvent } from 'react'
import styled from 'styled-components'

interface CurrencyInputProps {
  type?: string
  placeholder?: string
  value: string
  onChange: (event: ChangeEvent<HTMLInputElement>) => void
}

const StyledInput = styled.input`
  box-sizing: border-box;
  width: 100%;
  padding: 2px;
  background-color: transparent;
  color: ${({ theme }) => theme.neutral1};
  border: none;
  border-radius: 4px;
  font-family: 'Inter';
  font-size: 72px;
  font-weight: 600;
  text-align: center;
  outline: none;

  &::placeholder {
    color: ${({ theme }) => theme.neutral2};
  }
`

export const CurrencyInput: React.FC<CurrencyInputProps> = ({
  type = 'text',
  placeholder = '',
  value,
  onChange,
  ...props
}) => {
  return <StyledInput type={type} placeholder={placeholder} value={value} onChange={onChange} {...props} />
}
