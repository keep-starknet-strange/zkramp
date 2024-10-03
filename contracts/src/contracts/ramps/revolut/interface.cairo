use starknet::{ContractAddress, ClassHash};
use zkramp::components::registry::interface::OffchainId;

//
// Structs
//

#[derive(Drop, Copy, Serde)]
pub struct Proof {
    pub foo: felt252
}

#[derive(Drop, Copy, Hash, Serde, starknet::Store)]
pub struct LiquidityKey {
    pub owner: ContractAddress,
    pub offchain_id: OffchainId,
}

#[derive(Drop, Copy, Serde, starknet::Store)]
pub struct LiquidityShareRequest {
    pub requestor: ContractAddress,
    pub liquidity_key: LiquidityKey,
    pub amount: u256,
    pub expiration_date: u64,
}

//
// Interfaces
//

#[starknet::interface]
pub trait IZKRampLiquidity<TState> {
    fn all_liquidity(self: @TState, liquidity_key: LiquidityKey) -> u256;
    fn available_liquidity(self: @TState, liquidity_key: LiquidityKey) -> u256;
    fn liquidity_share_request(self: @TState, offchain_id: OffchainId) -> Option<LiquidityShareRequest>;
    fn add_liquidity(ref self: TState, amount: u256, offchain_id: OffchainId);
    fn retrieve_liquidity(ref self: TState, liquidity_key: LiquidityKey);
    fn initiate_liquidity_retrieval(ref self: TState, liquidity_key: LiquidityKey);
    fn initiate_liquidity_withdrawal(
        ref self: TState, liquidity_key: LiquidityKey, amount: u256, offchain_id: OffchainId
    );
    fn withdraw_liquidity(ref self: TState, liquidity_key: LiquidityKey, offchain_id: OffchainId, proof: Proof);
}

//
// full ABI
//

#[starknet::interface]
pub trait ZKRampABI<TState> {
    // IZKRampLiquidity
    fn all_liquidity(self: @TState, liquidity_key: LiquidityKey) -> u256;
    fn available_liquidity(self: @TState, liquidity_key: LiquidityKey) -> u256;
    fn liquidity_share_request(self: @TState, offchain_id: OffchainId) -> Option<LiquidityShareRequest>;
    fn add_liquidity(ref self: TState, amount: u256, offchain_id: OffchainId);
    fn retrieve_liquidity(ref self: TState, liquidity_key: LiquidityKey);
    fn initiate_liquidity_retrieval(ref self: TState, liquidity_key: LiquidityKey);
    fn initiate_liquidity_withdrawal(
        ref self: TState, liquidity_key: LiquidityKey, amount: u256, offchain_id: OffchainId
    );
    fn withdraw_liquidity(ref self: TState, liquidity_key: LiquidityKey, offchain_id: OffchainId, proof: Proof);

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
