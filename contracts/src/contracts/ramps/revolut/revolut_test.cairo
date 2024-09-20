use core::starknet::{ContractAddress, get_caller_address};
use openzeppelin::utils::serde::SerializedAppend;
use snforge_std::{declare, DeclareResultTrait, ContractClassTrait};
use zkramp::contracts::ramps::revolut::interface::{ZKRampABIDispatcher, ZKRampABIDispatcherTrait, LiquidityKey};
use openzeppelin::presets::interfaces::ERC20UpgradeableABIDispatcher;
use zkramp::tests::constants;
use zkramp::tests::utils;

fn setup_revolut_ramp(erc20_contract_address: ContractAddress) -> ZKRampABIDispatcher {
    // declare Revolut Ramp contract
    let revolut_ramp_contract_class = declare("RevolutRamp").unwrap().contract_class();

    // deploy revolut ramp
    let mut calldata = array![];

    calldata.append_serde(constants::OWNER());
    calldata.append_serde(erc20_contract_address);

    let (contract_address, _) = revolut_ramp_contract_class.deploy(@calldata).unwrap();

    ZKRampABIDispatcher { contract_address }
}

fn setup() -> (ZKRampABIDispatcher, ERC20UpgradeableABIDispatcher) {
    // deploy an ERC20
    let erc20 = utils::setup_erc20(constants::OWNER());

    // deploy revolut ramp
    let revolut_ramp = setup_revolut_ramp(erc20.contract_address);

    (revolut_ramp, erc20)
}

//
// Liquidity addition
//

#[test]
#[should_panic(expected: 'Caller is not registered')]
fn test_add_liquidity_with_unregistered_offchain_id() {
}

#[test]
#[should_panic(expected: 'Amount cannot be null')]
fn test_add_zero_liquidity() {
}

#[test]
fn test_add_liquidity() {
}

#[test]
fn test_add_liquidity_twice() {
}

#[test]
fn test_add_liquidity_to_locked_liquidity() {
}

//
// Liquidity retrieval
//

#[test]
#[should_panic(expected: 'Amount cannot be null')]
fn test_initiate_empty_liquidity_retrieval() {
}

#[test]
#[should_panic(expected: 'Caller is not the owner')]
fn test_initiate_liquidity_retrieval_not_owner() {
}

#[test]
fn test_initiate_liquidity_retrieval() {
}

#[test]
fn test_initiate_liquidity_retrieval_twice() {
}

#[test]
#[should_panic(expected: 'Liquidity is unlocked')]
fn test_retrieve_unlocked_liquidity() {
    let (revolut_ramp, _) = setup();

    let liquidity_key = LiquidityKey { owner: get_caller_address(), offchain_id: constants::REVOLUT_ID() };

    revolut_ramp.retrieve_liquidity(:liquidity_key);
}

#[test]
#[should_panic(expected: 'Caller is not the owner')]
fn test_retrieve_liquidity_not_owner() {
}

#[test]
fn test_retrieve_liquidity() {
}

#[test]
fn test_retrieve_liquidity_twice() {
}

#[test]
fn test_retrieve_requested_liquidity() {
}

//
// Liquidity withdrawal
//

#[test]
#[should_panic(expected: 'Caller is the owner')]
fn test_initiate_liquidity_withdraw_from_owner() {
}

#[test]
#[should_panic(expected: 'Amount cannot be null')]
fn test_initiate_empty_liquidity_withdraw() {
}

#[test]
#[should_panic(expected: 'Liquidity is not available')]
fn test_initiate_locked_liquidity_withdraw() {
}

#[test]
#[should_panic(expected: 'Caller is not registered')]
fn test_initiate_liquidity_withdraw_with_unregistered_offchain_id() {
}

#[test]
#[should_panic(expected: 'Not enough liquidity')]
fn test_initiate_liquidity_withdraw_without_enough_liquidity() {
}

#[test]
#[should_panic(expected: 'Not enough liquidity')]
fn test_initiate_liquidity_withdraw_without_enough_available_liquidity() {
}

#[test]
fn test_initiate_liquidity_withdraw() {
}

#[test]
#[should_panic(expected: 'This offchainID is busy')]
fn test_initiate_liquidity_withdraw_twice() {
}





#[test]
#[should_panic(expected: 'Liquidity share not available')]
fn test_withdraw_unrequested_liquidity_share() {
}

#[test]
#[should_panic(expected: 'Liquidity share not available')]
fn test_withdraw_expired_liquidity_share() {
}

#[test]
#[should_panic(expected: 'Liquidity share not available')]
fn test_withdraw_liquidity_from_another_caller() {
}

#[test]
#[should_panic(expected: 'Liquidity share not available')]
fn test_withdraw_liquidity_from_another_offchain_id() {
}

#[test]
fn test_withdraw_liquidity() {
}

#[test]
#[should_panic(expected: 'Liquidity share not available')]
fn test_withdraw_liquidity_twice() {
}

//
// Internals
//
