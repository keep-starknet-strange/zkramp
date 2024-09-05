import { StateCreator } from 'zustand'

import { StoreState } from './index'

export enum ModalType {
  WALLET_CONNECT,
  WALLET_OVERVIEW,
  PROOF_GENERATION,
}

export type ApplicationSlice = State & Actions

interface State {
  modal: ModalType | null
}

interface Actions {
  isModalOpened: (modal: ModalType) => boolean
  openModal: (modal: ModalType) => void
  closeModals: () => void
  toggleModal: (modal: ModalType) => void
}

export const createApplicationSlice: StateCreator<StoreState, [['zustand/immer', never]], [], ApplicationSlice> = (
  set,
  get
) => ({
  modal: null,

  isModalOpened: (modal) => get().modal === modal,
  openModal: (modal) => set({ modal }),
  closeModals: () => set({ modal: null }),
  toggleModal: (modal: ModalType) => set((state) => ({ modal: modal === state.modal ? null : modal })),
})
