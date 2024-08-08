import { useCallback } from 'react'
import { useBoundStore } from 'src/state'
import { ModalType } from 'src/state/application'
import { useShallow } from 'zustand/react/shallow'

// eslint-disable-next-line import/no-unused-modules
export function useCloseModal(): () => void {
  const { closeModals } = useBoundStore(useShallow((state) => ({ closeModals: state.closeModals })))

  return closeModals
}

function useModal(modal: ModalType): [boolean, () => void] {
  const { toggleModal, isModalOpened } = useBoundStore((state) => ({
    toggleModal: state.toggleModal,
    isModalOpened: state.isModalOpened,
  }))

  const isOpen = isModalOpened(modal)
  const toggle = useCallback(() => toggleModal(modal), [modal, toggleModal])

  return [isOpen, toggle]
}

export const useWalletConnectModal = () => useModal(ModalType.WALLET_CONNECT)
// eslint-disable-next-line import/no-unused-modules
export const useWalletOverviewModal = () => useModal(ModalType.WALLET_OVERVIEW)
