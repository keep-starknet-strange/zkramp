import { useState } from 'react'
import { PrimaryButton } from 'src/components/Button'
import { Card } from 'src/components/Card'
import { Column, Row } from 'src/components/Flex'
import { ThemedText } from 'src/theme/components'
import { styled } from 'styled-components'

const Layout = styled(Column)`
  margin: 0 auto;
  justify-content: center;
  gap: 16px;
  height: 100vh;
`
const RegistrationHeader = styled(Column)`
  display: flex;
  justify-content: space-between;
  flex-direction: row;
  width: 100%;
`

const StatusCardGroup = styled(Row)`
  width: 100%;
  justify-content: space-between;
`

const RegisterCard = styled(Card)`
  width: 560px;
`

export default function RegisterPage() {
  const [displayRegister, setDisplayRegister] = useState(false)

  return (
    <Layout>
      {displayRegister ? (
        <>
          <RegisterCard gap={16} alignItems="flex-start">
            <RegistrationHeader>
              <ThemedText.Title onClick={() => setDisplayRegister(false)} style={{ cursor: 'pointer' }}>
                Back
              </ThemedText.Title>
              <ThemedText.Title>New Registration</ThemedText.Title>
              <div></div>
            </RegistrationHeader>

            <Card gap={12} bg="surface">
              Use the ZKRamp browser assistant to generate proof a valid Revolut account. Submit the proof to complete
              registration.
            </Card>
          </RegisterCard>
          <RegisterCard gap={16} alignItems="flex-start">
            <RegistrationHeader>
              <ThemedText.Title>Registration Proofs</ThemedText.Title>
            </RegistrationHeader>

            <Card gap={12} bg="surface">
              No Revolut account proofs found. Please follow instructions in the browser sidebar to generate proof of an
              existing Revtag.
            </Card>

            <PrimaryButton>
              <ThemedText.Title>Open Sidebar</ThemedText.Title>
            </PrimaryButton>
          </RegisterCard>
        </>
      ) : (
        <>
          <ThemedText.HeadlineSmall>Revolut Registration</ThemedText.HeadlineSmall>
          <RegisterCard gap={16} alignItems="flex-start">
            <Card gap={12} bg="surface">
              You must register with a valid Revolut account to use ZKRamp. Your account details are hashed to conceal
              your identity.
            </Card>

            <Card gap={12} bg="surface">
              <StatusCardGroup gap={16}>
                <ThemedText.BodyPrimary>Status</ThemedText.BodyPrimary>
              </StatusCardGroup>

              <StatusCardGroup gap={16}>Not Registered</StatusCardGroup>
            </Card>

            <PrimaryButton onClick={() => setDisplayRegister(true)}>
              <ThemedText.Title>+ Register</ThemedText.Title>
            </PrimaryButton>
          </RegisterCard>
        </>
      )}
    </Layout>
  )
}
