use core::hash::{HashStateTrait, HashStateExTrait};
use core::poseidon::PoseidonTrait;

use core::starknet::{ContractAddress, contract_address_const, get_caller_address};

use snforge_std::{declare, ContractClassTrait, start_cheat_caller_address, test_address};
use zkramp::contracts::ramps::revolut::interface::{IzkRampABIDispatcher, IzkRampABIDispatcherTrait};
use zkramp::contracts::ramps::revolut::revolut::RevolutRamp::RevolutImpl;

use zkramp::tests::constants;

fn deploy_revolut_ramp() -> (IzkRampABIDispatcher, ContractAddress) {
    let contract = declare("RevolutRamp").unwrap();
    let owner: ContractAddress = contract_address_const::<'owner'>();
    let escrow: ContractAddress = contract_address_const::<'escrow'>();

    let mut constructor_calldata = array![owner.into(), escrow.into()];

    let (contract_address, _) = contract.deploy(@constructor_calldata).unwrap();

    let dispatcher = IzkRampABIDispatcher { contract_address };

    (dispatcher, contract_address)
}

#[test]
#[should_panic(expected: 'Empty liquidity retrieval')]
fn test_retrieve_uninitialized_liquidity_should_panic() {
    let test_address: ContractAddress = test_address();

    start_cheat_caller_address(test_address, constants::CALLER());

    let (revolut_ramp, _) = deploy_revolut_ramp();

    let liquidity_id = PoseidonTrait::new()
        .update_with(get_caller_address())
        .update_with(constants::REVOLUT_ID())
        .finalize();

    revolut_ramp.retrieve_liquidity(liquidity_id);
}
