use core::num::traits::Bounded;
use starknet::storage::StorageMapReadAccess;
use openzeppelin::presets::interfaces::ERC20UpgradeableABIDispatcherTrait;
use snforge_std::{start_cheat_caller_address, stop_cheat_caller_address, test_address};
use zkramp::components::escrow::escrow::EscrowComponent::EscrowImpl;
use zkramp::components::escrow::escrow_mock::{TestingStateDefault, ComponentState};
use zkramp::tests::constants;
use zkramp::tests::utils;

fn COMPONENT_STATE() -> ComponentState {
    Default::default()
}

fn setup() -> ComponentState {
    COMPONENT_STATE()
    // no more setup needed here
}

//
// lock
//

#[test]
fn test_lock() {
    let mut state = setup();
    let locker = constants::OWNER();
    let erc20 = utils::setup_erc20(recipient: locker);
    let contract_address = test_address();
    let amount: u256 = 42;

    // approve escrow to spend funds
    start_cheat_caller_address(erc20.contract_address, locker);
    erc20.approve(spender: contract_address, amount: Bounded::MAX);
    stop_cheat_caller_address(erc20.contract_address);

    // assert state before
    assert_eq!(erc20.balance_of(locker), constants::SUPPLY);
    assert_eq!(erc20.balance_of(contract_address), 0);
    assert_eq!(state.deposits.read((locker, erc20.contract_address)), 0);

    // lock
    state.lock(from: locker, token: erc20.contract_address, :amount);

    // assert state after
    assert_eq!(erc20.balance_of(locker), constants::SUPPLY - amount);
    assert_eq!(erc20.balance_of(contract_address), amount);
    assert_eq!(state.deposits.read((locker, erc20.contract_address)), amount);
}

#[test]
fn test_lock_zero() {
    let mut state = setup();
    let locker = constants::OWNER();
    let erc20 = utils::setup_erc20(recipient: locker);
    let contract_address = test_address();
    let amount: u256 = 0;

    // approve escrow to spend funds
    start_cheat_caller_address(erc20.contract_address, locker);
    erc20.approve(spender: contract_address, amount: Bounded::MAX);
    stop_cheat_caller_address(erc20.contract_address);

    // assert state before
    assert_eq!(erc20.balance_of(locker), constants::SUPPLY);
    assert_eq!(erc20.balance_of(contract_address), 0);
    assert_eq!(state.deposits.read((locker, erc20.contract_address)), 0);

    // lock
    state.lock(from: locker, token: erc20.contract_address, :amount);

    // assert state after
    assert_eq!(erc20.balance_of(locker), constants::SUPPLY - amount);
    assert_eq!(erc20.balance_of(contract_address), amount);
    assert_eq!(state.deposits.read((locker, erc20.contract_address)), amount);
}

#[test]
fn test_lock_twice() {
    let mut state = setup();
    let locker = constants::OWNER();
    let erc20 = utils::setup_erc20(recipient: locker);
    let contract_address = test_address();
    let amount1: u256 = 42;
    let amount2: u256 = 75;

    // approve escrow to spend funds
    start_cheat_caller_address(erc20.contract_address, locker);
    erc20.approve(spender: contract_address, amount: Bounded::MAX);
    stop_cheat_caller_address(erc20.contract_address);

    // assert state before
    assert_eq!(erc20.balance_of(locker), constants::SUPPLY);
    assert_eq!(erc20.balance_of(contract_address), 0);
    assert_eq!(state.deposits.read((locker, erc20.contract_address)), 0);

    // lock
    state.lock(from: locker, token: erc20.contract_address, amount: amount1);
    state.lock(from: locker, token: erc20.contract_address, amount: amount2);

    // assert state after
    assert_eq!(erc20.balance_of(locker), constants::SUPPLY - amount1 - amount2);
    assert_eq!(erc20.balance_of(contract_address), amount1 + amount2);
    assert_eq!(state.deposits.read((locker, erc20.contract_address)), amount1 + amount2);
}

#[test]
fn test_lock_multiple_tokens() {
    let mut state = setup();
    let locker = constants::OWNER();
    let erc20_1 = utils::setup_erc20(recipient: locker);
    let erc20_2 = utils::setup_erc20(recipient: locker);
    let contract_address = test_address();
    let amount1: u256 = 42;
    let amount2: u256 = 75;

    // approve escrow to spend funds for token 1
    start_cheat_caller_address(erc20_1.contract_address, locker);
    erc20_1.approve(spender: contract_address, amount: Bounded::MAX);
    stop_cheat_caller_address(erc20_1.contract_address);

    // approve escrow to spend funds for token 2
    start_cheat_caller_address(erc20_2.contract_address, locker);
    erc20_2.approve(spender: contract_address, amount: Bounded::MAX);
    stop_cheat_caller_address(erc20_2.contract_address);

    // assert state before
    assert_eq!(erc20_1.balance_of(locker), constants::SUPPLY);
    assert_eq!(erc20_1.balance_of(contract_address), 0);
    assert_eq!(state.deposits.read((locker, erc20_1.contract_address)), 0);
    assert_eq!(erc20_2.balance_of(locker), constants::SUPPLY);
    assert_eq!(erc20_2.balance_of(contract_address), 0);
    assert_eq!(state.deposits.read((locker, erc20_2.contract_address)), 0);

    // lock
    state.lock(from: locker, token: erc20_1.contract_address, amount: amount1);
    state.lock(from: locker, token: erc20_2.contract_address, amount: amount2);

    // assert state after
    assert_eq!(erc20_1.balance_of(locker), constants::SUPPLY - amount1);
    assert_eq!(erc20_1.balance_of(contract_address), amount1);
    assert_eq!(state.deposits.read((locker, erc20_1.contract_address)), amount1);
    assert_eq!(erc20_2.balance_of(locker), constants::SUPPLY - amount2);
    assert_eq!(erc20_2.balance_of(contract_address), amount2);
    assert_eq!(state.deposits.read((locker, erc20_2.contract_address)), amount2);
}

//
// unlock
//

#[test]
#[should_panic(expected: 'Insufficient deposit balance')]
fn test_unlock_without_lock() {
    let mut state = setup();
    let locker = constants::OWNER();
    let unlocker = constants::RECIPIENT();
    let erc20 = utils::setup_erc20(recipient: locker);
    let amount: u256 = 42;

    // unlock
    state.unlock(from: locker, to: unlocker, token: erc20.contract_address, :amount);
}

#[test]
#[should_panic(expected: 'Insufficient deposit balance')]
fn test_unlock_amount_too_high() {
    let mut state = setup();
    let locker = constants::OWNER();
    let unlocker = constants::RECIPIENT();
    let erc20 = utils::setup_erc20(recipient: locker);
    let contract_address = test_address();
    let amount: u256 = 42;

    // approve escrow to spend funds
    start_cheat_caller_address(erc20.contract_address, locker);
    erc20.approve(spender: contract_address, amount: Bounded::MAX);
    stop_cheat_caller_address(erc20.contract_address);

    // lock
    state.lock(from: locker, token: erc20.contract_address, :amount);

    // unlock
    state.unlock(from: locker, to: unlocker, token: erc20.contract_address, amount: amount + 1);
}

#[test]
#[should_panic(expected: 'Insufficient deposit balance')]
fn test_unlock_wrong_token() {
    let mut state = setup();
    let locker = constants::OWNER();
    let unlocker = constants::RECIPIENT();
    let erc20 = utils::setup_erc20(recipient: locker);
    let other_erc20 = utils::setup_erc20(recipient: locker);
    let contract_address = test_address();
    let amount: u256 = 42;

    // approve escrow to spend funds
    start_cheat_caller_address(erc20.contract_address, locker);
    erc20.approve(spender: contract_address, amount: Bounded::MAX);
    stop_cheat_caller_address(erc20.contract_address);

    // lock
    state.lock(from: locker, token: erc20.contract_address, :amount);

    // unlock
    state.unlock(from: locker, to: unlocker, token: other_erc20.contract_address, :amount);
}

#[test]
#[should_panic(expected: 'Insufficient deposit balance')]
fn test_unlock_from_wrong_locker() {
    let mut state = setup();
    let locker = constants::OWNER();
    let unlocker = constants::RECIPIENT();
    let other = constants::OTHER();
    let erc20 = utils::setup_erc20(recipient: locker);
    let contract_address = test_address();
    let amount: u256 = 42;

    // approve escrow to spend funds
    start_cheat_caller_address(erc20.contract_address, locker);
    erc20.approve(spender: contract_address, amount: Bounded::MAX);
    stop_cheat_caller_address(erc20.contract_address);

    // lock
    state.lock(from: locker, token: erc20.contract_address, :amount);

    // unlock
    state.unlock(from: other, to: unlocker, token: erc20.contract_address, :amount);
}

#[test]
fn test_unlock() {
    let mut state = setup();
    let locker = constants::OWNER();
    let unlocker = constants::RECIPIENT();
    let erc20 = utils::setup_erc20(recipient: locker);
    let contract_address = test_address();
    let amount: u256 = 42;

    // approve escrow to spend funds
    start_cheat_caller_address(erc20.contract_address, locker);
    erc20.approve(spender: contract_address, amount: Bounded::MAX);
    stop_cheat_caller_address(erc20.contract_address);

    // lock
    state.lock(from: locker, token: erc20.contract_address, :amount);

    // assert state before
    assert_eq!(erc20.balance_of(locker), constants::SUPPLY - amount);
    assert_eq!(erc20.balance_of(constants::RECIPIENT()), 0);
    assert_eq!(erc20.balance_of(contract_address), amount);

    // unlock
    state.unlock(from: locker, to: unlocker, token: erc20.contract_address, :amount);

    // assert state after
    assert_eq!(erc20.balance_of(locker), constants::SUPPLY - amount);
    assert_eq!(erc20.balance_of(unlocker), amount);
    assert_eq!(erc20.balance_of(contract_address), 0);
}

#[test]
fn test_unlock_twice() {
    let mut state = setup();
    let locker = constants::OWNER();
    let unlocker = constants::RECIPIENT();
    let erc20 = utils::setup_erc20(recipient: locker);
    let contract_address = test_address();
    let amount1: u256 = 42;
    let amount2: u256 = 75;

    // approve escrow to spend funds
    start_cheat_caller_address(erc20.contract_address, locker);
    erc20.approve(spender: contract_address, amount: Bounded::MAX);
    stop_cheat_caller_address(erc20.contract_address);

    // lock
    state.lock(from: locker, token: erc20.contract_address, amount: amount1 + amount2);

    // assert state before
    assert_eq!(erc20.balance_of(locker), constants::SUPPLY - amount1 - amount2);
    assert_eq!(erc20.balance_of(constants::RECIPIENT()), 0);
    assert_eq!(erc20.balance_of(contract_address), amount1 + amount2);

    // unlock
    state.unlock(from: locker, to: unlocker, token: erc20.contract_address, amount: amount1);
    state.unlock(from: locker, to: unlocker, token: erc20.contract_address, amount: amount2);

    // assert state after
    assert_eq!(erc20.balance_of(locker), constants::SUPPLY - amount1 - amount2);
    assert_eq!(erc20.balance_of(unlocker), amount1 + amount2);
    assert_eq!(erc20.balance_of(contract_address), 0);
}
