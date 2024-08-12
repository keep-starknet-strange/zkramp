import React, { ChangeEvent } from 'react'
import styled from 'styled-components'

interface CurrencyInputProps {
  type?: string
  placeholder?: string
  value: string
  onChange: (event: ChangeEvent<HTMLInputElement>) => void
}

const StyledInput = styled.input`
  padding: 2px;
  border: none;
  background-color: transparent;
  border-radius: 4px;
  font-size: 26px;
  width: 100%;
  box-sizing: border-box;
  color: white;

  &:focus {
    outline: none;
    // border-color: #66afe9;
    // box-shadow: 0 0 5px rgba(102, 175, 233, 0.5);
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
