use starknet::{SyscallResultTrait, syscalls};

pub fn deploy(contract_class_hash: felt252, calldata: Array<felt252>) -> starknet::ContractAddress {
    let (address, _) = syscalls::deploy_syscall(
        contract_class_hash.try_into().unwrap(), 0, calldata.span(), false
    )
        .unwrap_syscall();

    address
}
