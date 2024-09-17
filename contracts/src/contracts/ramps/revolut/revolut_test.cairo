use core::starknet::{ContractAddress, get_caller_address};
use openzeppelin::utils::serde::SerializedAppend;
use snforge_std::{declare, ContractClassTrait, start_cheat_caller_address, test_address};
use zkramp::contracts::ramps::revolut::interface::{ZKRampABIDispatcher, ZKRampABIDispatcherTrait, LiquidityKey};
use zkramp::tests::constants;

fn deploy_revolut_ramp() -> ZKRampABIDispatcher {
    let contract = declare("RevolutRamp").unwrap();

    let mut calldata = array![];

    calldata.append_serde(constants::OWNER());
    // TODO: give a relevant token address for better tests
    calldata.append_serde(constants::OWNER());

    let (contract_address, _) = contract.deploy(@calldata).unwrap();

    ZKRampABIDispatcher { contract_address }
}

#[test]
#[should_panic(expected: 'Unlocked liquidity retrieval')]
fn test_retrieve_uninitialized_liquidity_should_panic() {
    let test_address: ContractAddress = test_address();

    start_cheat_caller_address(test_address, constants::CALLER());

    let revolut_ramp = deploy_revolut_ramp();

    let liquidity_key = LiquidityKey { owner: get_caller_address(), offchain_id: constants::REVOLUT_ID() };

    revolut_ramp.retrieve_liquidity(:liquidity_key);
}
