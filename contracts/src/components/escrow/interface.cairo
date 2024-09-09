use core::hash::HashStateExTrait;
use starknet::ContractAddress;

#[starknet::interface]
pub trait IEscrow<TState> {
    fn lock_from(
        ref self: TState,
        from: ContractAddress,
        token: ContractAddress,
        amount: u256,
        duration: u256
    );
    fn unlock_to(
        ref self: TState,
        from: ContractAddress,
        to: ContractAddress,
        token: ContractAddress,
        amount: u256
    );

    fn init_lock_count(ref self: TState);
}

