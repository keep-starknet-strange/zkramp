use starknet::ContractAddress;
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
