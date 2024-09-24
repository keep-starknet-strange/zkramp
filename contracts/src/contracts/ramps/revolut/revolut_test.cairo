use openzeppelin_presets::interfaces::ERC20UpgradeableABIDispatcherTrait;
use core::starknet::{ContractAddress, get_caller_address};
use openzeppelin::presets::interfaces::ERC20UpgradeableABIDispatcher;
use openzeppelin::utils::serde::SerializedAppend;
use snforge_std::{declare, DeclareResultTrait, ContractClassTrait, 
    start_cheat_caller_address, 
    stop_cheat_caller_address, 
    // test_address,
    // spy_events
};
use zkramp::contracts::ramps::revolut::interface::{ZKRampABIDispatcher, ZKRampABIDispatcherTrait, LiquidityKey};
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
// add_liquidity
//

// #[test]
// #[should_panic(expected: 'Caller is not registered')]
fn test_add_liquidity_with_unregistered_offchain_id() {
    panic!("Not implemented yet");
}

// #[test]
// #[should_panic(expected: 'Amount cannot be null')]
fn test_add_zero_liquidity() {
    panic!("Not implemented yet");
}

// #[test]
fn test_add_liquidity() {
    panic!("Not implemented yet");
}

// #[test]
fn test_add_liquidity_twice() {
    panic!("Not implemented yet");
}

// #[test]
fn test_add_liquidity_to_locked_liquidity() {
    panic!("Not implemented yet");
}

//
// initiate_liquidity_retrival & retrieve_liquidity
//

// #[test]
// #[should_panic(expected: 'Amount cannot be null')]
fn test_initiate_empty_liquidity_retrieval() {
    panic!("Not implemented yet");
}

// #[test]
// #[should_panic(expected: 'Caller is not the owner')]
fn test_initiate_liquidity_retrieval_not_owner() {
    panic!("Not implemented yet");
}

// #[test]
fn test_initiate_liquidity_retrieval() {
    panic!("Not implemented yet");
}

// #[test]
fn test_initiate_liquidity_retrieval_twice() {
    panic!("Not implemented yet");
}

#[test]
#[should_panic(expected: 'Liquidity is unlocked')]
fn test_retrieve_unlocked_liquidity() {
    let (revolut_ramp, _) = setup();

    // create liquidity key
    let liquidity_key = LiquidityKey { owner: get_caller_address(), offchain_id: constants::REVOLUT_ID() };

    // try to retrieve liquidity
    revolut_ramp.retrieve_liquidity(:liquidity_key);
}

// #[test]
// #[should_panic(expected: 'Caller is not the owner')]
fn test_retrieve_liquidity_not_owner() {
    panic!("Not implemented yet");
}

// #[test]
fn test_retrieve_liquidity() {
    panic!("Not implemented yet");
}

// #[test]
fn test_retrieve_liquidity_twice() {
    panic!("Not implemented yet");
}

// #[test]
fn test_retrieve_liquidity_with_pending_requests() {
    panic!("Not implemented yet");
}

// #[test]
fn test_retrieve_liquidity_with_expired_requests() {
    panic!("Not implemented yet");
}

//
// initiate_liquidity_withdraw & withdraw_liquidity
//

// #[test]
// #[should_panic(expected: 'Caller is the owner')]
fn test_initiate_liquidity_withdraw_from_owner() {
    panic!("Not implemented yet");
}

// #[test]
// #[should_panic(expected: 'Amount cannot be null')]
fn test_initiate_liquidity_withdraw_zero_amount() {
    panic!("Not implemented yet");
}

// #[test]
// #[should_panic(expected: 'Liquidity is not available')]
fn test_initiate_liquidity_withdraw_locked() {
    panic!("Not implemented yet");
}

// #[test]
// #[should_panic(expected: 'Caller is not registered')]
fn test_initiate_liquidity_withdraw_with_unregistered_offchain_id() {
    panic!("Not implemented yet");
}

// #[test]
// #[should_panic(expected: 'Not enough liquidity')]
fn test_initiate_liquidity_withdraw_without_enough_liquidity() {
    panic!("Not implemented yet");
}

// #[test]
// #[should_panic(expected: 'Not enough liquidity')]
fn test_initiate_liquidity_withdraw_without_enough_available_liquidity() {
    panic!("Not implemented yet");
}

// #[test]
fn test_initiate_liquidity_withdraw() {
    panic!("Not implemented yet");
}

// #[test]
// #[should_panic(expected: 'This offchainID is busy')]
fn test_initiate_liquidity_withdraw_twice() {
    panic!("Not implemented yet");
}

// #[test]
// #[should_panic(expected: 'Liquidity share not available')]
fn test_withdraw_liquidity_without_request() {
    panic!("Not implemented yet");
}

// #[test]
// #[should_panic(expected: 'Liquidity share not available')]
fn test_withdraw_liquidity_after_expiration() {
    panic!("Not implemented yet");
}

// #[test]
// #[should_panic(expected: 'Liquidity share not available')]
fn test_withdraw_liquidity_from_another_caller() {
    panic!("Not implemented yet");
}

// #[test]
// #[should_panic(expected: 'Liquidity share not available')]
fn test_withdraw_liquidity_from_another_offchain_id() {
    panic!("Not implemented yet");
}

// #[test]
fn test_withdraw_liquidity() {
    panic!("Not implemented yet");
}

// #[test]
// #[should_panic(expected: 'Liquidity share not available')]
fn test_withdraw_liquidity_twice() {
    panic!("Not implemented yet");
}

//
// _get_next_timestamp_key
//

// #[test]
fn test__get_next_timestamp_key_basic() {
    panic!("Not implemented yet");
}

// #[test]
fn test__get_next_timestamp_key_for_timestamp_key() {
    panic!("Not implemented yet");
}

// #[test]
fn test__get_next_timestamp_key_from_zero() {
    panic!("Not implemented yet");
}

// #[test]
fn test_get_available_liquidity_basic() {
    panic!("Not implemented yet");
}

//
// available_liquidity & _get_available_liquidity
//

// #[test]
fn test_available_liquidity_empty() {
    panic!("Not implemented yet");
}

// #[test]
fn test_available_liquidity_without_requests() {
    panic!("Not implemented yet");
}

// #[test]
fn test_available_liquidity_locked() {
    panic!("Not implemented yet");
}

// #[test]
fn test_available_liquidity_with_expired_requests() {
    panic!("Not implemented yet");
}

// #[test]
fn test_available_liquidity_with_pending_requests() {
    panic!("Not implemented yet");
}

// #[test]
fn test_available_liquidity_with_withdrawn_requests() {
    panic!("Not implemented yet");
}

// #[test]
fn test__get_available_liquidity_empty() {
    panic!("Not implemented yet");
}

// #[test]
fn test__get_available_liquidity_without_requests() {
    panic!("Not implemented yet");
}

// #[test]
fn test__get_available_liquidity_with_expired_requests() {
    panic!("Not implemented yet");
}

// #[test]
fn test__get_available_liquidity_with_pending_requests() {
    panic!("Not implemented yet");
}

// #[test]
fn test__get_available_liquidity_with_withdrawn_requests() {
    panic!("Not implemented yet");
}

//
// all_liquidity
//

#[test]
fn test_all_liquidity_empty() {
    let (revolut_ramp, _) = setup();
    let revolut_address=revolut_ramp.contract_address;
    // setup caller
    start_cheat_caller_address(revolut_address, constants::OWNER());
    // register
    revolut_ramp.register(offchain_id: constants::REVOLUT_ID());
    // assert state after
    assert!(revolut_ramp.is_registered(constants::OWNER(), constants::REVOLUT_ID()));

    // create liquidity key
    let liquidity_key = LiquidityKey { owner: constants::OWNER(), offchain_id: constants::REVOLUT_ID() };

    // try to retrieve liquidity not created
    let liquidity= revolut_ramp.all_liquidity(:liquidity_key);
    assert(liquidity == 0, 'amount empty');
}

#[test]
fn test_all_liquidity() {
    let (revolut_ramp, erc20) = setup();
    let revolut_address=revolut_ramp.contract_address;
    let erc20_address=erc20.contract_address;
    // setup caller
    start_cheat_caller_address(revolut_address, constants::OWNER());
    // register
    revolut_ramp.register(offchain_id: constants::REVOLUT_ID());
    // assert state after
    assert!(revolut_ramp.is_registered(constants::OWNER(), constants::REVOLUT_ID()));

    // create liquidity key
    let liquidity_key = LiquidityKey { owner: constants::OWNER(), offchain_id: constants::REVOLUT_ID() };
    let amount=1_u256;
    let max_amount=10_u256;

    stop_cheat_caller_address(revolut_address);

    // Approve balance
    start_cheat_caller_address(erc20_address, constants::OWNER());
    erc20.approve(revolut_address, max_amount);

    stop_cheat_caller_address(erc20_address);

    // try to retrieve liquidity not created
    start_cheat_caller_address(revolut_address, constants::OWNER());
    let liquidity= revolut_ramp.all_liquidity(:liquidity_key);
    assert(liquidity == 0, 'amount init');

    revolut_ramp.add_liquidity(amount, offchain_id: constants::REVOLUT_ID() );
    assert_eq!(erc20.balance_of(revolut_address), amount);

    // try to get liquidity with the first amount added
    let liquidity= revolut_ramp.all_liquidity(:liquidity_key);
    assert(liquidity == amount, 'not correct amount');

    // Readd liquidity
    revolut_ramp.add_liquidity(amount, offchain_id: constants::REVOLUT_ID() );

    // REcheck the old and new amount are added
    let liquidity= revolut_ramp.all_liquidity(:liquidity_key);
    assert(liquidity == amount+amount, 'not correct amount');
    assert_eq!(erc20.balance_of(revolut_address), amount+amount);


    // TODO add withdraw request and recheck amount

}

// #[test]
fn test_all_liquidity_locked() {
    let (revolut_ramp, erc20) = setup();

    let revolut_address=revolut_ramp.contract_address;
    let erc20_address=erc20.contract_address;
    // setup caller
    start_cheat_caller_address(revolut_address, constants::OWNER());
    // register
    revolut_ramp.register(offchain_id: constants::REVOLUT_ID());
    // assert state after
    assert!(revolut_ramp.is_registered(constants::OWNER(), constants::REVOLUT_ID()));

    // create liquidity key
    let amount=1_u256;
    let max_amount=10_u256;

    stop_cheat_caller_address(revolut_address);

    // Approve balance
    start_cheat_caller_address(erc20_address, constants::OWNER());
    erc20.approve(revolut_address, max_amount);

    stop_cheat_caller_address(erc20_address);

    // try to retrieve liquidity not created
    start_cheat_caller_address(revolut_address, constants::OWNER());
    revolut_ramp.add_liquidity(amount, offchain_id: constants::REVOLUT_ID() );
    assert_eq!(erc20.balance_of(revolut_address), amount);

    // TODO how verify is token is locked
    // let liquidity_key = LiquidityKey { owner: constants::OWNER(), offchain_id: constants::REVOLUT_ID() };
    // let liquidity_available= revolut_ramp.available_liquidity(:liquidity_key);
    // TODO Verify if it's locked and the amount

}

// #[test]
fn test_all_liquidity_with_requests() {
    // TODO how verify is token is locked

    // TODO Verify if it's locked and the amount
    panic!("Not implemented yet");
}

//
// liquidity_share_request
//

// #[test]
fn test_liquidity_share_request_empty() {
    panic!("Not implemented yet");
}

// #[test]
fn test_liquidity_share_request_expired() {
    panic!("Not implemented yet");
}

// #[test]
fn test_liquidity_share_request_valid() {
    panic!("Not implemented yet");
}

// #[test]
fn test_liquidity_share_request_withdrawn() {
    panic!("Not implemented yet");
}
