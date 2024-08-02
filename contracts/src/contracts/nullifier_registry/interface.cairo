#[starknet::interface]
pub trait NullifierRegistryABI<TState> {
    fn is_nullified(self: @TState, nullifier: u256) -> bool;
    fn add_nullifier(ref self: TState, nullifier: u256);
}
