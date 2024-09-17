use starknet::{ContractAddress, ClassHash};
use zkramp::components::registry::interface::OffchainId;

#[derive(Drop, Serde)]
pub struct Proof {
    foo: felt252
}

#[derive(Drop, Copy, Hash, Serde)]
pub struct LiquidityKey {
    pub owner: ContractAddress,
    pub offchain_id: OffchainId,
}

#[starknet::interface]
pub trait IZKRampLiquidity<TState> {
    fn add_liquidity(ref self: TState, amount: u256, offchain_id: OffchainId);
    fn retrieve_liquidity(ref self: TState, liquidity_key: LiquidityKey);
    fn initiate_liquidity_retrieval(ref self: TState, liquidity_key: LiquidityKey);
}

#[starknet::interface]
pub trait ZKRampABI<TState> {
    // IZKRampLiquidity
    fn add_liquidity(ref self: TState, amount: u256, offchain_id: OffchainId);
    fn retrieve_liquidity(ref self: TState, liquidity_key: LiquidityKey);
    fn initiate_liquidity_retrieval(ref self: TState, liquidity_key: LiquidityKey);

    // IRegistry
    fn is_registered(self: @TState, contract_address: ContractAddress, offchain_id: OffchainId) -> bool;
    fn register(ref self: TState, offchain_id: OffchainId);

    // IOwnable
    fn owner(self: @TState) -> ContractAddress;
    fn transfer_ownership(ref self: TState, new_owner: ContractAddress);
    fn renounce_ownership(ref self: TState);

    // IOwnableCamelOnly
    fn transferOwnership(ref self: TState, newOwner: ContractAddress);
    fn renounceOwnership(ref self: TState);

    // IUpgradeable
    fn upgrade(ref self: TState, new_class_hash: ClassHash);
}
