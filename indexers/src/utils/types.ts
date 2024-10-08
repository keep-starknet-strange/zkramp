import { Plateform } from './constants.ts';

export interface OffchainId {
    plateform: Plateform
    id: string
}

export interface LiquidityKey {
    owner: string
    offchainId: OffchainId
}
