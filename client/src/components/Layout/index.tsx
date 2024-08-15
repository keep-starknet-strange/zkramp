import Header from 'src/components/Header'
import WalletSidebar from 'src/components/WalletSidebar'

export default function Layout({ children }: React.HTMLAttributes<HTMLDivElement>) {
  return (
    <>
      <Header />
      <WalletSidebar />
      {children}
    </>
  )
}
