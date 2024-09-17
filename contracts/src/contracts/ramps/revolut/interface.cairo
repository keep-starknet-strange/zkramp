use starknet::ContractAddress;
use zkramp::components::registry::interface::OffchainId;

#[derive(Drop, Serde)]
struct Proof {
    foo: felt252
}

#[derive(Drop, Copy, Hash)]
pub struct LiquidityKey {
    pub owner: ContractAddress,
    pub offchain_id: OffchainId,
}

#[starknet::interface]
pub trait IZKRampLiquidity<TState> {
    fn add_liquidity(ref self: TState, amount: u256, offchain_id: OffchainId);
}
