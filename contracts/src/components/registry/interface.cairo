use core::hash::HashStateExTrait;
use starknet::ContractAddress;
use zkramp::utils::hash::HashSerializable;

#[derive(Drop, Serde, Clone, Debug, PartialEq)]
pub enum OffchainId {
    Revolut: ByteArray
}

#[starknet::interface]
pub trait IRegistry<TState> {
    fn is_registered(
        self: @TState, contract_address: ContractAddress, offchain_id: OffchainId
    ) -> bool;
    fn register(ref self: TState, offchain_id: OffchainId);
}
