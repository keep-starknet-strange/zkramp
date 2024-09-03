import { useEffect, useState } from 'react'
import { PrimaryButton } from 'src/components/Button'
import { Column, Row } from 'src/components/Flex'
import { ThemedText } from 'src/theme/components'
import { LockClosed, LockOpen } from 'src/theme/components/icons'
import { styled, useTheme } from 'styled-components'

const Content = styled(Column)`
  max-width: 464px;
  width: 100%;
  margin: 120px auto 0;
`

const Headline = styled(Row)`
  width: 100%;
  justify-content: space-between;
  margin-bottom: 12px;
`

const ContentCard = styled(Column)`
  width: 100%;
  border-radius: 12px;
  overflow: hidden;
`

const NoDataCard = styled(Column)`
  width: 100%;
  align-items: center;
  justify-content: center;
  padding: 32px 0;
  background-color: ${({ theme }) => theme.bg3};
`

const RevtagCard = styled(Row)`
  width: 100%;
  justify-content: space-between;
  padding: 24px 16px;
  background-color: ${({ theme }) => theme.bg3};
`

const ProofCard = styled(Row)`
  width: 100%;
  justify-content: flex-end;
  gap: 8px;
  padding: 16px;
  background-color: ${({ theme }) => theme.bg2};
`

export default function RegisterPage() {
  const theme = useTheme()
  const [revtag, setRevtag] = useState('')
  const [generatingProof, setGeneratingProof] = useState(false)
  const [proven, setProven] = useState(false)

  useEffect(() => {
    if (generatingProof) {
      setTimeout(() => {
        setProven(true)
        setGeneratingProof(false)
      }, 5_000)
    }
  }, [generatingProof])

  return (
    <Content gap={12}>
      <Headline>
        <ThemedText.HeadlineLarge>Register</ThemedText.HeadlineLarge>
      </Headline>

      {!revtag && (
        <>
          <ContentCard>
            <NoDataCard>
              <ThemedText.BodyPrimary fontWeight={500}>No data detected</ThemedText.BodyPrimary>
            </NoDataCard>
          </ContentCard>

          <PrimaryButton onClick={() => setRevtag('chqrlesjuzw')}>Open sidebar</PrimaryButton>
        </>
      )}

      {revtag && (
        <>
          <ContentCard>
            <RevtagCard>
              <ThemedText.BodyPrimary>Revtag:</ThemedText.BodyPrimary>
              <ThemedText.BodyPrimary fontWeight={500}>{revtag}</ThemedText.BodyPrimary>
            </RevtagCard>

            <ProofCard>
              {proven ? (
                <LockClosed width={18} height={18} color={theme.green} />
              ) : (
                <LockOpen width={18} height={18} color={theme.neutral2} />
              )}

              {proven ? (
                <ThemedText.BodyPrimary>Proved</ThemedText.BodyPrimary>
              ) : (
                <ThemedText.BodySecondary fontWeight={500}>Unproved</ThemedText.BodySecondary>
              )}
            </ProofCard>
          </ContentCard>

          <PrimaryButton onClick={() => !proven && setGeneratingProof(true)}>
            <ThemedText.BodyPrimary>{proven ? 'Complete registration' : 'Generate proof'}</ThemedText.BodyPrimary>
          </PrimaryButton>
        </>
      )}
    </Content>
  )
}
