use starknet::ContractAddress;

#[starknet::interface]
pub trait IEscrow<TState> {
    fn lock(ref self: TState, from: ContractAddress, token: ContractAddress, amount: u256);
    fn unlock(ref self: TState, from: ContractAddress, to: ContractAddress, token: ContractAddress, amount: u256);
}
