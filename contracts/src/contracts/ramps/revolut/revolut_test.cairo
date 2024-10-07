use core::num::traits::Bounded;
use core::starknet::ContractAddress;
use openzeppelin::presets::interfaces::{ERC20UpgradeableABIDispatcher, ERC20UpgradeableABIDispatcherTrait};
use openzeppelin::utils::serde::SerializedAppend;
use snforge_std::{
    EventSpyAssertionsTrait, spy_events, declare, DeclareResultTrait, ContractClassTrait, start_cheat_caller_address,
    stop_cheat_caller_address, test_address, start_cheat_block_timestamp_global
};
use zkramp::contracts::ramps::revolut::interface::{ZKRampABIDispatcher, ZKRampABIDispatcherTrait, LiquidityKey};
use zkramp::contracts::ramps::revolut::revolut::RevolutRamp::{
    Event, LiquidityAdded, LiquidityRetrieved, LiquidityLocked, LiquidityShareRequested, LiquidityShareWithdrawn,
    InternalImpl as RevolutRampInternalImpl, MINIMUM_LOCK_DURATION, LOCK_DURATION_STEP
};
use zkramp::contracts::ramps::revolut::revolut::RevolutRamp;
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

#[test]
#[should_panic(expected: 'Caller is not registered')]
fn test_add_liquidity_with_unregistered_offchain_id() {
    let contract_address = test_address();
    let (revolut_ramp, _) = setup();
    let liquidity_owner = constants::CALLER();
    let offchain_id = constants::REVOLUT_ID();
    let amount = 42;

    start_cheat_caller_address(contract_address, liquidity_owner);

    // add liquidity with unregistered offchain id
    revolut_ramp.add_liquidity(:amount, :offchain_id);
}

#[test]
#[should_panic(expected: 'Amount cannot be null')]
fn test_add_zero_liquidity() {
    let contract_address = test_address();
    let (revolut_ramp, _) = setup();
    let liquidity_owner = constants::OTHER();
    let offchain_id = constants::REVOLUT_ID();
    let amount = 0;

    start_cheat_caller_address(contract_address, liquidity_owner);

    // register offchain id
    revolut_ramp.register(:offchain_id);

    // add zero liquidity
    revolut_ramp.add_liquidity(:amount, :offchain_id);
}

#[test]
fn test_add_liquidity() {
    let (revolut_ramp, erc20) = setup();
    let mut spy = spy_events();
    let liquidity_owner = constants::CALLER();
    let offchain_id = constants::REVOLUT_ID();
    let amount = 42;
    let liquidity_key = LiquidityKey { owner: liquidity_owner, offchain_id };

    // fund the account
    fund_and_approve(token: erc20, recipient: liquidity_owner, spender: revolut_ramp.contract_address, :amount);

    // register offchain ID
    start_cheat_caller_address(revolut_ramp.contract_address, liquidity_owner);
    revolut_ramp.register(:offchain_id);

    // assert state before
    assert_eq!(revolut_ramp.all_liquidity(:liquidity_key), 0);
    assert_eq!(revolut_ramp.available_liquidity(:liquidity_key), 0);
    assert_eq!(erc20.balance_of(liquidity_owner), amount);

    // add liquidity
    revolut_ramp.add_liquidity(amount, offchain_id);

    // assert state after
    assert_eq!(revolut_ramp.all_liquidity(:liquidity_key), amount);
    assert_eq!(revolut_ramp.available_liquidity(:liquidity_key), amount);
    assert_eq!(erc20.balance_of(liquidity_owner), 0);

    // check on emitted events
    spy
        .assert_emitted(
            @array![(revolut_ramp.contract_address, Event::LiquidityAdded(LiquidityAdded { liquidity_key, amount }))]
        )
}

#[test]
fn test_add_liquidity_twice() {
    let (revolut_ramp, erc20) = setup();
    let mut spy = spy_events();
    let liquidity_owner = constants::CALLER();
    let offchain_id = constants::REVOLUT_ID();
    let amount1 = 42;
    let amount2 = 75;
    let liquidity_key = LiquidityKey { owner: liquidity_owner, offchain_id };

    // fund the account
    fund_and_approve(
        token: erc20, recipient: liquidity_owner, spender: revolut_ramp.contract_address, amount: amount1 + amount2
    );

    // register offchain ID
    start_cheat_caller_address(revolut_ramp.contract_address, liquidity_owner);
    revolut_ramp.register(:offchain_id);

    assert_eq!(revolut_ramp.all_liquidity(liquidity_key), 0);
    assert_eq!(revolut_ramp.available_liquidity(liquidity_key), 0);
    assert_eq!(erc20.balance_of(liquidity_owner), amount1 + amount2);

    // add liquidity
    revolut_ramp.add_liquidity(amount: amount1, :offchain_id);
    revolut_ramp.add_liquidity(amount: amount2, :offchain_id);

    assert_eq!(revolut_ramp.all_liquidity(liquidity_key), amount1 + amount2);
    assert_eq!(revolut_ramp.available_liquidity(liquidity_key), amount1 + amount2);
    assert_eq!(erc20.balance_of(liquidity_owner), 0);

    // check on emitted events
    spy
        .assert_emitted(
            @array![
                (
                    revolut_ramp.contract_address,
                    Event::LiquidityAdded(LiquidityAdded { liquidity_key, amount: amount1 })
                ),
                (
                    revolut_ramp.contract_address,
                    Event::LiquidityAdded(LiquidityAdded { liquidity_key, amount: amount2 })
                )
            ]
        )
}

#[test]
fn test_add_liquidity_to_locked_liquidity() {
    let (revolut_ramp, erc20) = setup();
    let mut spy = spy_events();
    let liquidity_owner = constants::CALLER();
    let offchain_id = constants::REVOLUT_ID();
    let amount1 = 42;
    let amount2 = 75;
    let liquidity_key = LiquidityKey { owner: liquidity_owner, offchain_id };

    // fund the account
    fund_and_approve(
        token: erc20, recipient: liquidity_owner, spender: revolut_ramp.contract_address, amount: amount1 + amount2
    );

    // register offchain ID
    start_cheat_caller_address(revolut_ramp.contract_address, liquidity_owner);
    revolut_ramp.register(:offchain_id);

    // add liquidity
    revolut_ramp.add_liquidity(amount: amount1, :offchain_id);

    // locks liquidity
    revolut_ramp.initiate_liquidity_retrieval(:liquidity_key);

    assert_eq!(revolut_ramp.all_liquidity(liquidity_key), amount1);
    assert_eq!(revolut_ramp.available_liquidity(liquidity_key), 0);
    assert_eq!(erc20.balance_of(liquidity_owner), amount2);

    // add liquidity again
    revolut_ramp.add_liquidity(amount: amount2, :offchain_id);

    // assert state after
    assert_eq!(revolut_ramp.all_liquidity(liquidity_key), amount1 + amount2);
    assert_eq!(revolut_ramp.available_liquidity(liquidity_key), amount1 + amount2);
    assert_eq!(erc20.balance_of(liquidity_owner), 0);

    // check on emitted events
    spy
        .assert_emitted(
            @array![
                (
                    revolut_ramp.contract_address,
                    Event::LiquidityAdded(LiquidityAdded { liquidity_key, amount: amount1 })
                ),
                (
                    revolut_ramp.contract_address,
                    Event::LiquidityAdded(LiquidityAdded { liquidity_key, amount: amount2 })
                )
            ]
        )
}

//
// initiate_liquidity_retrieval & retrieve_liquidity
//

#[test]
#[should_panic(expected: 'Amount cannot be null')]
fn test_initiate_liquidity_retrieval_empty() {
    // setup
    let (revolut_ramp, _) = setup();
    let caller = constants::CALLER();
    let offchain_id = constants::REVOLUT_ID();
    let liquidity_key = LiquidityKey { owner: caller, offchain_id };

    // initiate liquidity retrieval
    revolut_ramp.initiate_liquidity_retrieval(liquidity_key);
}

#[test]
#[should_panic(expected: 'Caller is not the owner')]
fn test_initiate_liquidity_retrieval_not_owner() {
    let (revolut_ramp, erc20) = setup();
    let liquidity_owner = constants::CALLER();
    let other_caller = constants::OTHER();
    let offchain_id = constants::REVOLUT_ID();
    let amount = 42;
    let liquidity_key = LiquidityKey { owner: liquidity_owner, offchain_id };

    // fund the account
    fund_and_approve(token: erc20, recipient: liquidity_owner, spender: revolut_ramp.contract_address, :amount);

    // register offchain ID
    start_cheat_caller_address(revolut_ramp.contract_address, liquidity_owner);
    revolut_ramp.register(:offchain_id);

    // add liquidity
    revolut_ramp.add_liquidity(:amount, :offchain_id);

    // initiate liquidity retrieval with wrong owner
    start_cheat_caller_address(revolut_ramp.contract_address, other_caller);
    revolut_ramp.initiate_liquidity_retrieval(:liquidity_key);
}

#[test]
fn test_initiate_liquidity_retrieval() {
    let (revolut_ramp, erc20) = setup();
    let mut spy = spy_events();
    let liquidity_owner = constants::OTHER();
    let offchain_id = constants::REVOLUT_ID();
    let amount = 42;
    let liquidity_key = LiquidityKey { owner: liquidity_owner, offchain_id };

    // fund the account
    fund_and_approve(token: erc20, recipient: liquidity_owner, spender: revolut_ramp.contract_address, :amount);

    // register offchain ID
    start_cheat_caller_address(revolut_ramp.contract_address, liquidity_owner);
    revolut_ramp.register(:offchain_id);

    // add liquidity
    revolut_ramp.add_liquidity(amount, offchain_id);

    // assert state before
    assert_eq!(revolut_ramp.all_liquidity(:liquidity_key), amount);
    assert_eq!(revolut_ramp.available_liquidity(:liquidity_key), amount);
    assert_eq!(erc20.balance_of(liquidity_owner), 0);

    revolut_ramp.initiate_liquidity_retrieval(:liquidity_key);

    // assert state after
    assert_eq!(revolut_ramp.all_liquidity(:liquidity_key), amount);
    assert_eq!(revolut_ramp.available_liquidity(:liquidity_key), 0);
    assert_eq!(erc20.balance_of(liquidity_owner), 0);

    // check on emitted events
    spy
        .assert_emitted(
            @array![(revolut_ramp.contract_address, Event::LiquidityLocked(LiquidityLocked { liquidity_key }))]
        )
}

#[test]
fn test_initiate_liquidity_retrieval_twice() {
    let (revolut_ramp, erc20) = setup();
    let mut spy = spy_events();
    let liquidity_owner = constants::OTHER();
    let offchain_id = constants::REVOLUT_ID();
    let amount = 42;
    let liquidity_key = LiquidityKey { owner: liquidity_owner, offchain_id };

    // fund the account
    fund_and_approve(token: erc20, recipient: liquidity_owner, spender: revolut_ramp.contract_address, :amount);

    // register offchain ID
    start_cheat_caller_address(revolut_ramp.contract_address, liquidity_owner);
    revolut_ramp.register(:offchain_id);

    // add liquidity
    revolut_ramp.add_liquidity(amount, offchain_id);

    // assert state before
    assert_eq!(revolut_ramp.all_liquidity(:liquidity_key), amount);
    assert_eq!(revolut_ramp.available_liquidity(:liquidity_key), amount);
    assert_eq!(erc20.balance_of(liquidity_owner), 0);

    revolut_ramp.initiate_liquidity_retrieval(:liquidity_key);
    revolut_ramp.initiate_liquidity_retrieval(:liquidity_key);

    // assert state after
    assert_eq!(revolut_ramp.all_liquidity(:liquidity_key), amount);
    assert_eq!(revolut_ramp.available_liquidity(:liquidity_key), 0);
    assert_eq!(erc20.balance_of(liquidity_owner), 0);

    // check on emitted events
    spy
        .assert_emitted(
            @array![
                (revolut_ramp.contract_address, Event::LiquidityLocked(LiquidityLocked { liquidity_key })),
                (revolut_ramp.contract_address, Event::LiquidityLocked(LiquidityLocked { liquidity_key }))
            ]
        )
}

#[test]
#[should_panic(expected: 'Liquidity is unlocked')]
fn test_retrieve_unlocked_liquidity() {
    let (revolut_ramp, erc20) = setup();
    let liquidity_owner = constants::CALLER();
    let offchain_id = constants::REVOLUT_ID();
    let amount = 42;
    let liquidity_key = LiquidityKey { owner: liquidity_owner, offchain_id };

    // fund the account
    fund_and_approve(token: erc20, recipient: liquidity_owner, spender: revolut_ramp.contract_address, :amount);

    // register offchain ID
    start_cheat_caller_address(revolut_ramp.contract_address, liquidity_owner);
    revolut_ramp.register(:offchain_id);

    // add liquidity
    revolut_ramp.add_liquidity(amount, offchain_id);

    // try to retrieve liquidity
    revolut_ramp.retrieve_liquidity(:liquidity_key);
}

#[test]
#[should_panic(expected: 'Caller is not the owner')]
fn test_retrieve_liquidity_not_owner() {
    let (revolut_ramp, erc20) = setup();
    let liquidity_owner = constants::CALLER();
    let other_caller = constants::OTHER();
    let offchain_id = constants::REVOLUT_ID();
    let amount = 42;
    let liquidity_key = LiquidityKey { owner: liquidity_owner, offchain_id };

    // fund the account
    fund_and_approve(token: erc20, recipient: liquidity_owner, spender: revolut_ramp.contract_address, :amount);

    // register offchain ID
    start_cheat_caller_address(revolut_ramp.contract_address, liquidity_owner);
    revolut_ramp.register(:offchain_id);

    // add liquidity
    revolut_ramp.add_liquidity(amount, offchain_id);

    // initiate liquidity retrieval
    revolut_ramp.initiate_liquidity_retrieval(:liquidity_key);

    // retrieve liquidity as other caller
    start_cheat_caller_address(revolut_ramp.contract_address, other_caller);
    revolut_ramp.retrieve_liquidity(:liquidity_key);
}

#[test]
fn test_retrieve_liquidity() {
    let (revolut_ramp, erc20) = setup();
    let mut spy = spy_events();
    let liquidity_owner = constants::CALLER();
    let offchain_id = constants::REVOLUT_ID();
    let amount = 42;
    let liquidity_key = LiquidityKey { owner: liquidity_owner, offchain_id };

    // fund the account
    fund_and_approve(token: erc20, recipient: liquidity_owner, spender: revolut_ramp.contract_address, :amount);

    // register offchain ID
    start_cheat_caller_address(revolut_ramp.contract_address, liquidity_owner);
    revolut_ramp.register(:offchain_id);

    // add liquidity
    revolut_ramp.add_liquidity(:amount, :offchain_id);

    // initiate liquidity retrieval
    revolut_ramp.initiate_liquidity_retrieval(:liquidity_key);

    // assert state before
    assert_eq!(revolut_ramp.all_liquidity(:liquidity_key), amount);
    assert_eq!(revolut_ramp.available_liquidity(:liquidity_key), 0);
    assert_eq!(erc20.balance_of(liquidity_owner), 0);

    // retrieve liquidity
    revolut_ramp.retrieve_liquidity(:liquidity_key);

    // assert state after
    assert_eq!(revolut_ramp.all_liquidity(:liquidity_key), 0);
    assert_eq!(revolut_ramp.available_liquidity(:liquidity_key), 0);
    assert_eq!(erc20.balance_of(liquidity_owner), amount);

    // check on emitted events
    spy
        .assert_emitted(
            @array![
                (revolut_ramp.contract_address, Event::LiquidityRetrieved(LiquidityRetrieved { liquidity_key, amount }))
            ]
        )
}

#[test]
fn test_retrieve_liquidity_twice() {
    let (revolut_ramp, erc20) = setup();
    let mut spy = spy_events();
    let liquidity_owner = constants::CALLER();
    let offchain_id = constants::REVOLUT_ID();
    let amount1 = 42;
    let amount2 = 75;
    let liquidity_key = LiquidityKey { owner: liquidity_owner, offchain_id };

    // fund the account
    fund_and_approve(
        token: erc20, recipient: liquidity_owner, spender: revolut_ramp.contract_address, amount: amount1 + amount2
    );

    // register offchain ID
    start_cheat_caller_address(revolut_ramp.contract_address, liquidity_owner);
    revolut_ramp.register(:offchain_id);

    // add liquidity
    revolut_ramp.add_liquidity(amount: amount1, :offchain_id);

    // initiate liquidity retrieval
    revolut_ramp.initiate_liquidity_retrieval(:liquidity_key);

    // assert state before
    assert_eq!(revolut_ramp.all_liquidity(:liquidity_key), amount1);
    assert_eq!(revolut_ramp.available_liquidity(:liquidity_key), 0);
    assert_eq!(erc20.balance_of(liquidity_owner), amount2);

    // retrieve liquidity first time
    revolut_ramp.retrieve_liquidity(:liquidity_key);

    // assert state after
    assert_eq!(revolut_ramp.all_liquidity(:liquidity_key), 0);
    assert_eq!(revolut_ramp.available_liquidity(:liquidity_key), 0);
    assert_eq!(erc20.balance_of(liquidity_owner), amount1 + amount2);

    // add second liquidity
    revolut_ramp.add_liquidity(amount: amount2, :offchain_id);

    // initiate liquidity retrieval
    revolut_ramp.initiate_liquidity_retrieval(:liquidity_key);

    // assert state before
    assert_eq!(revolut_ramp.all_liquidity(:liquidity_key), amount2);
    assert_eq!(revolut_ramp.available_liquidity(:liquidity_key), 0);
    assert_eq!(erc20.balance_of(liquidity_owner), amount1);

    // retrieve liquidity second time
    revolut_ramp.retrieve_liquidity(:liquidity_key);

    // assert state after
    assert_eq!(revolut_ramp.all_liquidity(:liquidity_key), 0);
    assert_eq!(revolut_ramp.available_liquidity(:liquidity_key), 0);
    assert_eq!(erc20.balance_of(liquidity_owner), amount1 + amount2);

    // check on emitted events
    spy
        .assert_emitted(
            @array![
                (
                    revolut_ramp.contract_address,
                    Event::LiquidityRetrieved(LiquidityRetrieved { liquidity_key, amount: amount1 })
                ),
                (
                    revolut_ramp.contract_address,
                    Event::LiquidityRetrieved(LiquidityRetrieved { liquidity_key, amount: amount2 })
                )
            ]
        )
}

#[test]
fn test_retrieve_liquidity_with_pending_requests() {
    let (revolut_ramp, erc20) = setup();
    let mut spy = spy_events();

    // off-ramper
    let liquidity_owner = constants::CALLER();
    let offchain_id = constants::REVOLUT_ID();
    let amount = 100;

    // on-ramper
    let withdrawer = constants::OTHER();
    let withdrawer_offchain_id = constants::REVOLUT_ID2();
    let requested_amount = 42;
    let liquidity_key = LiquidityKey { owner: liquidity_owner, offchain_id };

    // fund the account
    fund_and_approve(token: erc20, recipient: liquidity_owner, spender: revolut_ramp.contract_address, amount: amount);

    // register offchain ID
    start_cheat_caller_address(revolut_ramp.contract_address, liquidity_owner);
    revolut_ramp.register(:offchain_id);

    // add liquidity
    revolut_ramp.add_liquidity(:amount, :offchain_id);

    // withdrawer initiates withdrawal
    start_cheat_caller_address(revolut_ramp.contract_address, withdrawer);
    revolut_ramp.register(offchain_id: withdrawer_offchain_id);
    revolut_ramp
        .initiate_liquidity_withdrawal(:liquidity_key, amount: requested_amount, offchain_id: withdrawer_offchain_id);

    // liquidity owner retrieves
    start_cheat_caller_address(revolut_ramp.contract_address, liquidity_owner);
    revolut_ramp.initiate_liquidity_retrieval(:liquidity_key);

    // assert state before
    assert_eq!(revolut_ramp.all_liquidity(:liquidity_key), amount);
    assert_eq!(revolut_ramp.available_liquidity(:liquidity_key), 0);
    assert_eq!(erc20.balance_of(liquidity_owner), 0);

    // retrieve liquidity
    revolut_ramp.retrieve_liquidity(:liquidity_key);

    // assert state after 1st liquidity retrieval
    assert_eq!(revolut_ramp.all_liquidity(:liquidity_key), requested_amount);
    assert_eq!(revolut_ramp.available_liquidity(:liquidity_key), 0);
    assert_eq!(erc20.balance_of(liquidity_owner), amount - requested_amount);

    // offer expires
    start_cheat_block_timestamp_global(MINIMUM_LOCK_DURATION);

    // retrieve liquidity
    revolut_ramp.retrieve_liquidity(:liquidity_key);

    // assert state after 2nd liquidity retrieval
    assert_eq!(revolut_ramp.all_liquidity(:liquidity_key), 0);
    assert_eq!(revolut_ramp.available_liquidity(:liquidity_key), 0);
    assert_eq!(erc20.balance_of(liquidity_owner), amount);

    // check on emitted events
    spy
        .assert_emitted(
            @array![
                (
                    revolut_ramp.contract_address,
                    Event::LiquidityRetrieved(LiquidityRetrieved { liquidity_key, amount: amount - requested_amount })
                ),
                (
                    revolut_ramp.contract_address,
                    Event::LiquidityRetrieved(LiquidityRetrieved { liquidity_key, amount: requested_amount })
                )
            ]
        )
}

#[test]
fn test_retrieve_liquidity_with_expired_requests() {
    let (revolut_ramp, erc20) = setup();
    let mut spy = spy_events();

    // off-ramper with 100 in liquidity
    let liquidity_owner = constants::CALLER();
    let offchain_id = constants::REVOLUT_ID();
    let amount = 100;

    // on-ramper will be requesting 42
    let withdrawer = constants::OTHER();
    let withdrawer_offchain_id = constants::REVOLUT_ID2();
    let requested_amount = 42;
    let liquidity_key = LiquidityKey { owner: liquidity_owner, offchain_id };

    // fund the account
    fund_and_approve(token: erc20, recipient: liquidity_owner, spender: revolut_ramp.contract_address, :amount);

    // register offchain ID
    start_cheat_caller_address(revolut_ramp.contract_address, liquidity_owner);
    revolut_ramp.register(:offchain_id);

    // add liquidity
    revolut_ramp.add_liquidity(:amount, :offchain_id);

    // withdrawer registers and initiates withdrawal
    start_cheat_caller_address(revolut_ramp.contract_address, withdrawer);
    revolut_ramp.register(offchain_id: withdrawer_offchain_id);
    revolut_ramp
        .initiate_liquidity_withdrawal(:liquidity_key, amount: requested_amount, offchain_id: withdrawer_offchain_id);

    // liquidity owner initiates retrieve
    start_cheat_caller_address(revolut_ramp.contract_address, liquidity_owner);
    revolut_ramp.initiate_liquidity_retrieval(:liquidity_key);

    // offer expires
    start_cheat_block_timestamp_global(MINIMUM_LOCK_DURATION);

    // assert state before
    assert_eq!(revolut_ramp.all_liquidity(:liquidity_key), amount);
    assert_eq!(revolut_ramp.available_liquidity(:liquidity_key), 0);
    assert_eq!(erc20.balance_of(liquidity_owner), 0);

    // retrieve liquidity
    revolut_ramp.retrieve_liquidity(:liquidity_key);

    // assert state after
    assert_eq!(revolut_ramp.all_liquidity(:liquidity_key), 0);
    assert_eq!(revolut_ramp.available_liquidity(:liquidity_key), 0);
    assert_eq!(erc20.balance_of(liquidity_owner), amount);

    // check on emitted events
    spy
        .assert_emitted(
            @array![
                (revolut_ramp.contract_address, Event::LiquidityRetrieved(LiquidityRetrieved { liquidity_key, amount }))
            ]
        )
}

//
// initiate_liquidity_withdraw & withdraw_liquidity
//

#[test]
#[should_panic(expected: 'Caller is the owner')]
fn test_initiate_liquidity_withdraw_from_owner() {
    let (revolut_ramp, erc20) = setup();
    let liquidity_owner = constants::CALLER();
    let offchain_id = constants::REVOLUT_ID();
    let amount = 42;
    let liquidity_key = LiquidityKey { owner: liquidity_owner, offchain_id };

    // fund the account
    fund_and_approve(token: erc20, recipient: liquidity_owner, spender: revolut_ramp.contract_address, :amount);

    // register offchain ID
    start_cheat_caller_address(revolut_ramp.contract_address, liquidity_owner);
    revolut_ramp.register(:offchain_id);

    // add liquidity
    revolut_ramp.add_liquidity(:amount, :offchain_id);

    // initiate liquidity withdraw
    revolut_ramp.initiate_liquidity_withdrawal(:liquidity_key, :amount, :offchain_id);
}

#[test]
#[should_panic(expected: 'Amount cannot be null')]
fn test_initiate_liquidity_withdraw_zero_amount() {
    let (revolut_ramp, erc20) = setup();
    let liquidity_owner = constants::CALLER();
    let liquidity_withdrawer = constants::OTHER();
    let offchain_id = constants::REVOLUT_ID();
    let withdrawer_offchain_id = constants::REVOLUT_ID2();
    let amount = 42;
    let liquidity_key = LiquidityKey { owner: liquidity_owner, offchain_id };

    // fund the account
    fund_and_approve(token: erc20, recipient: liquidity_owner, spender: revolut_ramp.contract_address, :amount);

    // register offchain ID owner
    start_cheat_caller_address(revolut_ramp.contract_address, liquidity_owner);
    revolut_ramp.register(:offchain_id);

    // add liquidity
    revolut_ramp.add_liquidity(:amount, :offchain_id);

    // register offchain ID withdrawer
    start_cheat_caller_address(revolut_ramp.contract_address, liquidity_withdrawer);
    revolut_ramp.register(offchain_id: withdrawer_offchain_id);

    // initiate liquidity withdraw
    revolut_ramp.initiate_liquidity_withdrawal(:liquidity_key, amount: 0, offchain_id: withdrawer_offchain_id);
}

#[test]
#[should_panic(expected: 'Liquidity is not available')]
fn test_initiate_liquidity_withdraw_locked() {
    let (revolut_ramp, erc20) = setup();
    let liquidity_owner = constants::CALLER();
    let liquidity_withdrawer = constants::OTHER();
    let offchain_id = constants::REVOLUT_ID();
    let withdrawer_offchain_id = constants::REVOLUT_ID2();
    let amount = 42;
    let liquidity_key = LiquidityKey { owner: liquidity_owner, offchain_id };

    // fund the account
    fund_and_approve(token: erc20, recipient: liquidity_owner, spender: revolut_ramp.contract_address, :amount);

    // register offchain ID owner
    start_cheat_caller_address(revolut_ramp.contract_address, liquidity_owner);
    revolut_ramp.register(:offchain_id);

    // add liquidity
    revolut_ramp.add_liquidity(:amount, :offchain_id);

    // locks liquidity
    revolut_ramp.initiate_liquidity_retrieval(:liquidity_key);

    // register offchain ID withdrawer
    start_cheat_caller_address(revolut_ramp.contract_address, liquidity_withdrawer);
    revolut_ramp.register(offchain_id: withdrawer_offchain_id);

    // initiate liquidity withdraw
    revolut_ramp.initiate_liquidity_withdrawal(:liquidity_key, :amount, offchain_id: withdrawer_offchain_id);
}

#[test]
#[should_panic(expected: 'Caller is not registered')]
fn test_initiate_liquidity_withdraw_with_unregistered_offchain_id() {
    let (revolut_ramp, erc20) = setup();
    let liquidity_owner = constants::CALLER();
    let liquidity_withdrawer = constants::OTHER();
    let offchain_id = constants::REVOLUT_ID();
    let withdrawer_offchain_id = constants::REVOLUT_ID2();
    let amount = 42;
    let liquidity_key = LiquidityKey { owner: liquidity_owner, offchain_id };

    // fund the account
    fund_and_approve(token: erc20, recipient: liquidity_owner, spender: revolut_ramp.contract_address, :amount);

    // register offchain ID owner
    start_cheat_caller_address(revolut_ramp.contract_address, liquidity_owner);
    revolut_ramp.register(:offchain_id);

    // add liquidity
    revolut_ramp.add_liquidity(:amount, :offchain_id);

    // initiate liquidity withdraw
    start_cheat_caller_address(revolut_ramp.contract_address, liquidity_withdrawer);
    revolut_ramp.initiate_liquidity_withdrawal(:liquidity_key, :amount, offchain_id: withdrawer_offchain_id);
}

#[test]
#[should_panic(expected: 'Not enough liquidity')]
fn test_initiate_liquidity_withdraw_without_enough_liquidity() {
    let (revolut_ramp, erc20) = setup();
    let liquidity_owner = constants::CALLER();
    let liquidity_withdrawer = constants::OTHER();
    let offchain_id = constants::REVOLUT_ID();
    let withdrawer_offchain_id = constants::REVOLUT_ID2();
    let amount = 42;
    let liquidity_key = LiquidityKey { owner: liquidity_owner, offchain_id };

    // fund the account
    fund_and_approve(token: erc20, recipient: liquidity_owner, spender: revolut_ramp.contract_address, :amount);

    // register offchain ID owner
    start_cheat_caller_address(revolut_ramp.contract_address, liquidity_owner);
    revolut_ramp.register(:offchain_id);

    // add liquidity
    revolut_ramp.add_liquidity(:amount, :offchain_id);

    // register offchain ID withdrawer
    start_cheat_caller_address(revolut_ramp.contract_address, liquidity_withdrawer);
    revolut_ramp.register(offchain_id: withdrawer_offchain_id);

    // initiate liquidity withdraw
    revolut_ramp.initiate_liquidity_withdrawal(:liquidity_key, amount: amount + 1, offchain_id: withdrawer_offchain_id);
}

#[test]
#[should_panic(expected: 'Not enough liquidity')]
fn test_initiate_liquidity_withdraw_without_enough_available_liquidity() {
    let (revolut_ramp, erc20) = setup();
    let liquidity_owner = constants::CALLER();
    let liquidity_withdrawer1 = constants::OTHER();
    let liquidity_withdrawer2 = constants::OTHER2();
    let offchain_id = constants::REVOLUT_ID();
    let withdrawer_offchain_id1 = constants::REVOLUT_ID2();
    let withdrawer_offchain_id2 = constants::REVOLUT_ID3();
    let amount = 42;
    let liquidity_key = LiquidityKey { owner: liquidity_owner, offchain_id };

    // fund the account
    fund_and_approve(token: erc20, recipient: liquidity_owner, spender: revolut_ramp.contract_address, :amount);

    // register offchain ID owner
    start_cheat_caller_address(revolut_ramp.contract_address, liquidity_owner);
    revolut_ramp.register(:offchain_id);

    // add liquidity
    revolut_ramp.add_liquidity(:amount, :offchain_id);

    // register offchain ID withdrawer 1
    start_cheat_caller_address(revolut_ramp.contract_address, liquidity_withdrawer1);
    revolut_ramp.register(offchain_id: withdrawer_offchain_id1);

    // initiate liquidity withdraw
    revolut_ramp.initiate_liquidity_withdrawal(:liquidity_key, amount: 1, offchain_id: withdrawer_offchain_id1);

    // assert state before
    assert_eq!(revolut_ramp.available_liquidity(:liquidity_key), amount - 1);
    assert_eq!(revolut_ramp.all_liquidity(:liquidity_key), amount);

    // register offchain ID withdrawer 2
    start_cheat_caller_address(revolut_ramp.contract_address, liquidity_withdrawer2);
    revolut_ramp.register(offchain_id: withdrawer_offchain_id2);

    // initiate liquidity withdraw
    revolut_ramp.initiate_liquidity_withdrawal(:liquidity_key, :amount, offchain_id: withdrawer_offchain_id2);
}

#[test]
fn test_initiate_liquidity_withdraw() {
    let (revolut_ramp, erc20) = setup();
    let mut spy = spy_events();
    let liquidity_owner = constants::CALLER();
    let liquidity_withdrawer = constants::OTHER();
    let offchain_id = constants::REVOLUT_ID();
    let withdrawer_offchain_id = constants::REVOLUT_ID2();
    let amount = 42;
    let liquidity_key = LiquidityKey { owner: liquidity_owner, offchain_id };

    // fund the account
    fund_and_approve(token: erc20, recipient: liquidity_owner, spender: revolut_ramp.contract_address, :amount);

    // register offchain ID owner
    start_cheat_caller_address(revolut_ramp.contract_address, liquidity_owner);
    revolut_ramp.register(:offchain_id);

    // add liquidity
    revolut_ramp.add_liquidity(:amount, :offchain_id);

    // assert state before
    assert_eq!(revolut_ramp.all_liquidity(:liquidity_key), amount);
    assert_eq!(revolut_ramp.available_liquidity(:liquidity_key), amount);
    assert_eq!(erc20.balance_of(liquidity_owner), 0);

    // register offchain ID withdrawer
    start_cheat_caller_address(revolut_ramp.contract_address, liquidity_withdrawer);
    revolut_ramp.register(offchain_id: withdrawer_offchain_id);

    // initiate liquidity withdraw
    revolut_ramp.initiate_liquidity_withdrawal(:liquidity_key, :amount, offchain_id: withdrawer_offchain_id);

    // assert state after
    assert_eq!(revolut_ramp.all_liquidity(liquidity_key), amount);
    assert_eq!(revolut_ramp.available_liquidity(liquidity_key), 0);
    assert_eq!(erc20.balance_of(liquidity_owner), 0);

    // check on emitted events
    spy
        .assert_emitted(
            @array![
                (
                    revolut_ramp.contract_address,
                    Event::LiquidityShareRequested(
                        LiquidityShareRequested {
                            requestor: liquidity_withdrawer,
                            amount,
                            liquidity_key,
                            offchain_id: withdrawer_offchain_id,
                            expiration_date: MINIMUM_LOCK_DURATION
                        }
                    )
                )
            ]
        )
}

#[test]
#[should_panic(expected: 'This offchainID is busy')]
fn test_initiate_liquidity_withdraw_twice() {
    let (revolut_ramp, erc20) = setup();
    let liquidity_owner = constants::OTHER();
    let liquidity_withdrawer = constants::CALLER();
    let offchain_id = constants::REVOLUT_ID();
    let withdrawer_offchain_id = constants::REVOLUT_ID2();
    let amount1 = 42;
    let amount2 = 75;
    let liquidity_key = LiquidityKey { owner: liquidity_owner, offchain_id };

    // fund the account
    fund_and_approve(
        token: erc20, recipient: liquidity_owner, spender: revolut_ramp.contract_address, amount: amount1 + amount2
    );

    // register offchain ID owner
    start_cheat_caller_address(revolut_ramp.contract_address, liquidity_owner);
    revolut_ramp.register(:offchain_id);

    // add liquidity
    revolut_ramp.add_liquidity(amount: amount1 + amount2, :offchain_id);

    // register offchain ID withdrawer
    start_cheat_caller_address(revolut_ramp.contract_address, liquidity_withdrawer);
    revolut_ramp.register(offchain_id: withdrawer_offchain_id);

    // initiate liquidity withdraw
    revolut_ramp.initiate_liquidity_withdrawal(:liquidity_key, amount: amount1, offchain_id: withdrawer_offchain_id);
    revolut_ramp.initiate_liquidity_withdrawal(:liquidity_key, amount: amount2, offchain_id: withdrawer_offchain_id);
}

#[test]
#[should_panic(expected: 'Liquidity share not available')]
fn test_withdraw_liquidity_without_request() {
    let (revolut_ramp, erc20) = setup();

    // off-ramper
    let liquidity_owner = constants::CALLER();
    let offchain_id = constants::REVOLUT_ID();
    let amount = 42;

    // on-ramper
    let withdrawer = constants::OTHER();
    let withdrawer_offchain_id = constants::REVOLUT_ID2();
    let liquidity_key = LiquidityKey { owner: liquidity_owner, offchain_id };
    let proof = constants::PROOF();

    // fund the account
    fund_and_approve(token: erc20, recipient: liquidity_owner, spender: revolut_ramp.contract_address, amount: amount);

    // register offchain ID
    start_cheat_caller_address(revolut_ramp.contract_address, liquidity_owner);
    revolut_ramp.register(:offchain_id);

    // add liquidity
    revolut_ramp.add_liquidity(:amount, :offchain_id);

    // withdrawer tries to withdraw
    start_cheat_caller_address(revolut_ramp.contract_address, withdrawer);
    revolut_ramp.register(offchain_id: withdrawer_offchain_id);
    revolut_ramp.withdraw_liquidity(:liquidity_key, offchain_id: withdrawer_offchain_id, :proof);
}

#[test]
#[should_panic(expected: 'Liquidity share not available')]
fn test_withdraw_liquidity_after_expiration() {
    let (revolut_ramp, erc20) = setup();

    // off-ramper
    let liquidity_owner = constants::CALLER();
    let offchain_id = constants::REVOLUT_ID();
    let amount = 42;

    // on-ramper
    let withdrawer = constants::OTHER();
    let withdrawer_offchain_id = constants::REVOLUT_ID2();
    let liquidity_key = LiquidityKey { owner: liquidity_owner, offchain_id };
    let proof = constants::PROOF();

    // fund the account
    fund_and_approve(token: erc20, recipient: liquidity_owner, spender: revolut_ramp.contract_address, amount: amount);

    // register offchain ID
    start_cheat_caller_address(revolut_ramp.contract_address, liquidity_owner);
    revolut_ramp.register(:offchain_id);

    // add liquidity
    revolut_ramp.add_liquidity(:amount, :offchain_id);

    // withdrawer initiates withdrawal
    start_cheat_caller_address(revolut_ramp.contract_address, withdrawer);
    revolut_ramp.register(offchain_id: withdrawer_offchain_id);
    revolut_ramp.initiate_liquidity_withdrawal(:liquidity_key, :amount, offchain_id: withdrawer_offchain_id);

    // offer expires
    start_cheat_block_timestamp_global(MINIMUM_LOCK_DURATION);

    // withdrawer withdraws
    revolut_ramp.withdraw_liquidity(:liquidity_key, offchain_id: withdrawer_offchain_id, :proof);
}

#[test]
#[should_panic(expected: 'Liquidity share not available')]
fn test_withdraw_liquidity_from_another_caller() {
    let (revolut_ramp, erc20) = setup();

    // off-ramper
    let liquidity_owner = constants::CALLER();
    let offchain_id = constants::REVOLUT_ID();
    let amount = 42;

    // on-ramper
    let withdrawer = constants::OTHER();
    let withdrawer_offchain_id = constants::REVOLUT_ID2();

    // other on-ramper
    let other_withdrawer = constants::OTHER2();

    let liquidity_key = LiquidityKey { owner: liquidity_owner, offchain_id };
    let proof = constants::PROOF();

    // fund the account
    fund_and_approve(token: erc20, recipient: liquidity_owner, spender: revolut_ramp.contract_address, amount: amount);

    // register offchain ID
    start_cheat_caller_address(revolut_ramp.contract_address, liquidity_owner);
    revolut_ramp.register(:offchain_id);

    // add liquidity
    revolut_ramp.add_liquidity(:amount, :offchain_id);

    // withdrawer initiates withdrawal
    start_cheat_caller_address(revolut_ramp.contract_address, withdrawer);
    revolut_ramp.register(offchain_id: withdrawer_offchain_id);
    revolut_ramp.initiate_liquidity_withdrawal(:liquidity_key, :amount, offchain_id: withdrawer_offchain_id);

    // other caller tries to withdraw
    start_cheat_caller_address(revolut_ramp.contract_address, other_withdrawer);
    revolut_ramp.withdraw_liquidity(:liquidity_key, offchain_id: offchain_id, :proof);
}

#[test]
#[should_panic(expected: 'Liquidity share not available')]
fn test_withdraw_liquidity_from_another_offchain_id() {
    let (revolut_ramp, erc20) = setup();

    // off-ramper
    let liquidity_owner = constants::CALLER();
    let offchain_id = constants::REVOLUT_ID();
    let amount = 42;

    // on-ramper
    let withdrawer = constants::OTHER();
    let withdrawer_offchain_id = constants::REVOLUT_ID2();
    let liquidity_key = LiquidityKey { owner: liquidity_owner, offchain_id };
    let proof = constants::PROOF();

    // other on-ramper
    let other_withdrawer_offchain_id = constants::REVOLUT_ID3();

    // fund the account
    fund_and_approve(token: erc20, recipient: liquidity_owner, spender: revolut_ramp.contract_address, amount: amount);

    // register offchain ID
    start_cheat_caller_address(revolut_ramp.contract_address, liquidity_owner);
    revolut_ramp.register(:offchain_id);

    // add liquidity
    revolut_ramp.add_liquidity(:amount, :offchain_id);

    // withdrawer initiates withdrawal
    start_cheat_caller_address(revolut_ramp.contract_address, withdrawer);
    revolut_ramp.register(offchain_id: withdrawer_offchain_id);
    revolut_ramp.initiate_liquidity_withdrawal(:liquidity_key, :amount, offchain_id: withdrawer_offchain_id);

    // other offchain-id tries to withdraw
    revolut_ramp.withdraw_liquidity(:liquidity_key, offchain_id: other_withdrawer_offchain_id, :proof);
}

#[test]
fn test_withdraw_liquidity() {
    let (revolut_ramp, erc20) = setup();
    let mut spy = spy_events();

    // off-ramper
    let liquidity_owner = constants::CALLER();
    let offchain_id = constants::REVOLUT_ID();
    let amount = 42;

    // on-ramper
    let withdrawer = constants::OTHER();
    let withdrawer_offchain_id = constants::REVOLUT_ID2();

    let liquidity_key = LiquidityKey { owner: liquidity_owner, offchain_id };
    let proof = constants::PROOF();

    // fund the account
    fund_and_approve(token: erc20, recipient: liquidity_owner, spender: revolut_ramp.contract_address, amount: amount);

    // register offchain ID
    start_cheat_caller_address(revolut_ramp.contract_address, liquidity_owner);
    revolut_ramp.register(:offchain_id);

    // add liquidity
    revolut_ramp.add_liquidity(:amount, :offchain_id);

    // assert state before
    assert_eq!(revolut_ramp.all_liquidity(:liquidity_key), amount);
    assert_eq!(revolut_ramp.available_liquidity(:liquidity_key), amount);
    assert_eq!(erc20.balance_of(withdrawer), 0);

    // withdrawer initiates withdrawal
    start_cheat_caller_address(revolut_ramp.contract_address, withdrawer);
    revolut_ramp.register(offchain_id: withdrawer_offchain_id);
    revolut_ramp.initiate_liquidity_withdrawal(:liquidity_key, :amount, offchain_id: withdrawer_offchain_id);

    // withdrawer withdraws
    revolut_ramp.withdraw_liquidity(:liquidity_key, offchain_id: withdrawer_offchain_id, :proof);

    // assert state after
    assert_eq!(revolut_ramp.all_liquidity(:liquidity_key), 0);
    assert_eq!(revolut_ramp.available_liquidity(:liquidity_key), 0);
    assert_eq!(erc20.balance_of(withdrawer), amount);

    // check on emitted events
    spy
        .assert_emitted(
            @array![
                (
                    revolut_ramp.contract_address,
                    Event::LiquidityShareWithdrawn(
                        LiquidityShareWithdrawn {
                            liquidity_key, amount, withdrawer, offchain_id: withdrawer_offchain_id,
                        }
                    )
                )
            ]
        )
}

#[test]
#[should_panic(expected: 'Liquidity share not available')]
fn test_withdraw_liquidity_twice() {
    let (revolut_ramp, erc20) = setup();

    // off-ramper
    let liquidity_owner = constants::CALLER();
    let offchain_id = constants::REVOLUT_ID();
    let amount = 42;

    // on-ramper
    let withdrawer = constants::OTHER();
    let withdrawer_offchain_id = constants::REVOLUT_ID2();

    let proof = constants::PROOF();
    let liquidity_key = LiquidityKey { owner: liquidity_owner, offchain_id };

    // fund the account
    fund_and_approve(token: erc20, recipient: liquidity_owner, spender: revolut_ramp.contract_address, amount: amount);

    // register offchain ID
    start_cheat_caller_address(revolut_ramp.contract_address, liquidity_owner);
    revolut_ramp.register(:offchain_id);

    // add liquidity
    revolut_ramp.add_liquidity(:amount, :offchain_id);

    // withdrawer initiates withdrawal
    start_cheat_caller_address(revolut_ramp.contract_address, withdrawer);
    revolut_ramp.register(offchain_id: withdrawer_offchain_id);
    revolut_ramp.initiate_liquidity_withdrawal(:liquidity_key, :amount, offchain_id: withdrawer_offchain_id);

    // withdrawer withdraws
    revolut_ramp.withdraw_liquidity(:liquidity_key, offchain_id: withdrawer_offchain_id, :proof);

    // withdrawer withdraws again
    revolut_ramp.withdraw_liquidity(:liquidity_key, offchain_id: withdrawer_offchain_id, :proof);
}

//
// _get_next_timestamp_key
//

#[test]
fn test__get_next_timestamp_key_basic() {
    // setup
    let state = RevolutRamp::contract_state_for_testing();

    // test a value between 0 and LOCK_DURATION_STEP
    let after = 42;

    // should be rounded to the next threshold
    assert_eq!(state._get_next_timestamp_key(:after), LOCK_DURATION_STEP);
}

#[test]
fn test__get_next_timestamp_key_for_timestamp_key() {
    // setup
    let state = RevolutRamp::contract_state_for_testing();

    // test a multiple of LOCK_DURATION_STEP
    let after = LOCK_DURATION_STEP * 42;

    // should return the same value
    assert_eq!(state._get_next_timestamp_key(:after), after);
}

#[test]
fn test__get_next_timestamp_key_from_zero() {
    // setup
    let state = RevolutRamp::contract_state_for_testing();

    // test with 0
    let after = 0;

    // should return the same value
    assert_eq!(state._get_next_timestamp_key(:after), 0);
}

//
// available_liquidity & _get_available_liquidity
//

#[test]
fn test_available_liquidity_empty() {
    let (revolut_ramp, _) = setup();
    let liquidity_owner = constants::CALLER();
    let offchain_id = constants::REVOLUT_ID();
    let liquidity_key = LiquidityKey { owner: liquidity_owner, offchain_id };

    // assert no liquidity available
    assert_eq!(revolut_ramp.available_liquidity(:liquidity_key), 0);
}

#[test]
fn test_available_liquidity_without_requests() {
    let (revolut_ramp, erc20) = setup();
    let liquidity_owner = constants::CALLER();
    let offchain_id = constants::REVOLUT_ID();
    let amount = 42;
    let liquidity_key = LiquidityKey { owner: liquidity_owner, offchain_id };

    // fund the account
    fund_and_approve(token: erc20, recipient: liquidity_owner, spender: revolut_ramp.contract_address, :amount);

    // register offchain ID
    start_cheat_caller_address(revolut_ramp.contract_address, liquidity_owner);
    revolut_ramp.register(:offchain_id);

    // add liquidity
    revolut_ramp.add_liquidity(:amount, :offchain_id);

    // assert liquidity is available
    assert_eq!(revolut_ramp.available_liquidity(:liquidity_key), amount);
}

#[test]
fn test_available_liquidity_locked() {
    let (revolut_ramp, erc20) = setup();
    let liquidity_owner = constants::CALLER();
    let offchain_id = constants::REVOLUT_ID();
    let amount = 42;
    let liquidity_key = LiquidityKey { owner: liquidity_owner, offchain_id };

    // fund the account
    fund_and_approve(token: erc20, recipient: liquidity_owner, spender: revolut_ramp.contract_address, :amount);

    // register offchain ID
    start_cheat_caller_address(revolut_ramp.contract_address, liquidity_owner);
    revolut_ramp.register(:offchain_id);

    // add liquidity
    revolut_ramp.add_liquidity(:amount, :offchain_id);

    // initiate retrieval, locking liquidity
    revolut_ramp.initiate_liquidity_retrieval(:liquidity_key);

    // assert liquidity is not available
    assert_eq!(revolut_ramp.available_liquidity(:liquidity_key), 0);
}

#[test]
fn test_available_liquidity_with_expired_requests() {
    let (revolut_ramp, erc20) = setup();

    // off-ramper
    let liquidity_owner = constants::CALLER();
    let offchain_id = constants::REVOLUT_ID();
    let liquidity_key = LiquidityKey { owner: liquidity_owner, offchain_id };
    let amount = 100;

    // on-ramper
    let withdrawer = constants::OTHER();
    let withdrawer_offchain_id = constants::REVOLUT_ID2();
    let requested_amount = 42;

    // fund the account
    fund_and_approve(token: erc20, recipient: liquidity_owner, spender: revolut_ramp.contract_address, amount: amount);

    // register offchain ID
    start_cheat_caller_address(revolut_ramp.contract_address, liquidity_owner);
    revolut_ramp.register(:offchain_id);

    // add liquidity
    revolut_ramp.add_liquidity(:amount, :offchain_id);

    // withdrawer initiates withdrawal
    start_cheat_caller_address(revolut_ramp.contract_address, withdrawer);
    revolut_ramp.register(offchain_id: withdrawer_offchain_id);
    revolut_ramp
        .initiate_liquidity_withdrawal(:liquidity_key, amount: requested_amount, offchain_id: withdrawer_offchain_id);

    // assert state before expiration
    assert_eq!(revolut_ramp.all_liquidity(:liquidity_key), amount);
    assert_eq!(revolut_ramp.available_liquidity(:liquidity_key), amount - requested_amount);

    // offer expires
    start_cheat_block_timestamp_global(MINIMUM_LOCK_DURATION);

    // assert state after expiration
    assert_eq!(revolut_ramp.all_liquidity(:liquidity_key), amount);
    assert_eq!(revolut_ramp.available_liquidity(:liquidity_key), amount);
}

#[test]
fn test_available_liquidity_with_pending_requests() {
    let (revolut_ramp, erc20) = setup();

    // off-ramper
    let liquidity_owner = constants::CALLER();
    let offchain_id = constants::REVOLUT_ID();
    let liquidity_key = LiquidityKey { owner: liquidity_owner, offchain_id };
    let amount = 100;

    // on-ramper
    let withdrawer = constants::OTHER();
    let withdrawer_offchain_id = constants::REVOLUT_ID2();
    let requested_amount = 42;

    // fund the account
    fund_and_approve(token: erc20, recipient: liquidity_owner, spender: revolut_ramp.contract_address, amount: amount);

    // register offchain ID
    start_cheat_caller_address(revolut_ramp.contract_address, liquidity_owner);
    revolut_ramp.register(:offchain_id);

    // add liquidity
    revolut_ramp.add_liquidity(:amount, :offchain_id);

    // assert state before withdrawal initiated
    assert_eq!(revolut_ramp.all_liquidity(:liquidity_key), amount);
    assert_eq!(revolut_ramp.available_liquidity(:liquidity_key), amount);

    // withdrawer initiates withdrawal
    start_cheat_caller_address(revolut_ramp.contract_address, withdrawer);
    revolut_ramp.register(offchain_id: withdrawer_offchain_id);
    revolut_ramp
        .initiate_liquidity_withdrawal(:liquidity_key, amount: requested_amount, offchain_id: withdrawer_offchain_id);

    // assert state after withdrawal initiated
    assert_eq!(revolut_ramp.all_liquidity(:liquidity_key), amount);
    assert_eq!(revolut_ramp.available_liquidity(:liquidity_key), amount - requested_amount);

    // offer almost expires
    start_cheat_block_timestamp_global(MINIMUM_LOCK_DURATION - 1);

    // assert state when offer is close to expiration
    assert_eq!(revolut_ramp.all_liquidity(:liquidity_key), amount);
    assert_eq!(revolut_ramp.available_liquidity(:liquidity_key), amount - requested_amount);
}

#[test]
fn test_available_liquidity_with_withdrawn_requests() {
    let (revolut_ramp, erc20) = setup();

    // off-ramper
    let liquidity_owner = constants::CALLER();
    let offchain_id = constants::REVOLUT_ID();
    let liquidity_key = LiquidityKey { owner: liquidity_owner, offchain_id };
    let amount = 100;

    // on-ramper
    let withdrawer = constants::OTHER();
    let withdrawer_offchain_id = constants::REVOLUT_ID2();
    let requested_amount = 42;
    let proof = constants::PROOF();

    // fund the account
    fund_and_approve(token: erc20, recipient: liquidity_owner, spender: revolut_ramp.contract_address, amount: amount);

    // register offchain ID
    start_cheat_caller_address(revolut_ramp.contract_address, liquidity_owner);
    revolut_ramp.register(:offchain_id);

    // add liquidity
    revolut_ramp.add_liquidity(:amount, :offchain_id);

    // withdrawer initiates withdrawal
    start_cheat_caller_address(revolut_ramp.contract_address, withdrawer);
    revolut_ramp.register(offchain_id: withdrawer_offchain_id);
    revolut_ramp
        .initiate_liquidity_withdrawal(:liquidity_key, amount: requested_amount, offchain_id: withdrawer_offchain_id);

    // assert state before withdrawal
    assert_eq!(revolut_ramp.all_liquidity(:liquidity_key), amount);
    assert_eq!(revolut_ramp.available_liquidity(:liquidity_key), amount - requested_amount);

    // withdrawers withdraws liquidity
    revolut_ramp.withdraw_liquidity(:liquidity_key, offchain_id: withdrawer_offchain_id, :proof);

    // assert state after withdrawal
    assert_eq!(revolut_ramp.all_liquidity(:liquidity_key), amount - requested_amount);
    assert_eq!(revolut_ramp.available_liquidity(:liquidity_key), amount - requested_amount);
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

// #[test]
fn test_all_liquidity_empty() {
    panic!("Not implemented yet");
}

// #[test]
fn test_all_liquidity() {
    panic!("Not implemented yet");
}

// #[test]
fn test_all_liquidity_locked() {
    panic!("Not implemented yet");
}

// #[test]
fn test_all_liquidity_with_requests() {
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

//
// Helpers
//

fn fund(token: ERC20UpgradeableABIDispatcher, recipient: ContractAddress, amount: u256) {
    // fund from owner
    start_cheat_caller_address(token.contract_address, constants::OWNER());
    token.transfer(:recipient, :amount);
    stop_cheat_caller_address(token.contract_address);
}

fn fund_and_approve(
    token: ERC20UpgradeableABIDispatcher, recipient: ContractAddress, spender: ContractAddress, amount: u256
) {
    fund(:token, :recipient, :amount);

    // approve
    start_cheat_caller_address(token.contract_address, recipient);
    token.approve(:spender, amount: Bounded::MAX);
    stop_cheat_caller_address(token.contract_address);
}
