use starknet::ContractAddress;
use zkramp::utils::hash::HashSerializable;

#[derive(Drop, Copy, Serde, Debug, PartialEq, starknet::Store)]
pub enum OffchainId {
    Revolut: felt252
}

#[starknet::interface]
pub trait IRegistry<TState> {
    fn is_registered(self: @TState, contract_address: ContractAddress, offchain_id: OffchainId) -> bool;
    fn register(ref self: TState, offchain_id: OffchainId);
}
