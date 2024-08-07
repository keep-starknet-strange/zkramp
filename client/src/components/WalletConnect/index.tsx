import ConnectWalletButton from '../ConnectWalletButton'
import WalletConnectModal from './Modal'

// eslint-disable-next-line import/no-unused-modules
export default function WalletConnect() {
  return (
    <>
      <ConnectWalletButton label="Connect Wallet" backgroundColor="#fff" textColor="#000" />
      <WalletConnectModal />
    </>
  )
}
