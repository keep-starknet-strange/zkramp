use starknet::ContractAddress;

#[starknet::interface]
pub trait INullifierRegistry<TContractState> {
    fn is_nullified(self: @TContractState, nullifier: u256) -> bool;
    fn add_nullifier(ref self: TContractState, nullifier: u256);
    fn add_write_permissions(ref self: TContractState, new_writer: ContractAddress);
    fn remove_writer_permissions(ref self: TContractState, remove_writer: ContractAddress);
    fn get_writers(self: @TContractState) -> Array<ContractAddress>;
    fn is_writer(self: @TContractState, writer: ContractAddress) -> bool;
}
