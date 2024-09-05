import { Link } from 'react-router-dom'
import { PrimaryButton } from 'src/components/Button'
import { Column, Row } from 'src/components/Flex'
import { ThemedText } from 'src/theme/components'
import { Empty, Plus } from 'src/theme/components/icons'
import { styled } from 'styled-components'

const Content = styled(Column)`
  max-width: 850px;
  width: 100%;
  margin: 120px auto 0;
`

const Headline = styled(Row)`
  width: 100%;
  justify-content: space-between;
  margin-bottom: 12px;
`

const RegisterButton = styled(PrimaryButton)`
  width: auto;
  gap: 3px;
  padding: 8px;
  color: ${({ theme }) => theme.neutral1};
`

const ContentCard = styled(Column)`
  width: 100%;
  min-height: 220px;
  padding: 20px 16px;
  border: 1px solid ${({ theme }) => theme.border2};
  border-radius: 20px;
`

const EmptyCard = styled(Column)`
  flex: 1;
  align-items: center;
  justify-content: center;
  gap: 8px;
  color: ${({ theme }) => theme.neutral1};
`

export default function RegistrationPage() {
  return (
    <Content gap={12}>
      <Headline>
        <ThemedText.HeadlineLarge>Registration</ThemedText.HeadlineLarge>

        <RegisterButton as={Link} to="/registration/register">
          <Plus width={13} height={13} />
          Register
        </RegisterButton>
      </Headline>

      <ContentCard>
        <EmptyCard>
          <Empty width={42} height={42} />

          <ThemedText.BodyPrimary textAlign="center" maxWidth={220}>
            Your registered accounts will appear here.
          </ThemedText.BodyPrimary>
        </EmptyCard>
      </ContentCard>
    </Content>
  )
}
