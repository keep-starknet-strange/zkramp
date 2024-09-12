use core::starknet::get_contract_address;

use openzeppelin::presets::interfaces::ERC20UpgradeableABIDispatcherTrait;
use snforge_std::{start_cheat_caller_address, EventSpyAssertionsTrait, spy_events};
use zkramp::components::escrow::escrow::EscrowComponent::{Event, Locked, UnLocked, EscrowImpl};
use zkramp::components::escrow::escrow_mock::{TestingStateDefault, ComponentState};
use zkramp::tests::constants;
use zkramp::tests::utils;


//
// Externals
//

#[test]
fn test_lock() {
    let mut spy = spy_events();
    let token_dispatcher = utils::setup_erc20(recipient: constants::OWNER());
    start_cheat_caller_address(token_dispatcher.contract_address, constants::OWNER());

    token_dispatcher.transfer(constants::SPENDER(), 100);

    start_cheat_caller_address(token_dispatcher.contract_address, constants::SPENDER());

    token_dispatcher.approve(constants::RECIPIENT(), 42);
    start_cheat_caller_address(token_dispatcher.contract_address, constants::RECIPIENT());

    let mut escrow: ComponentState = Default::default();

    escrow.lock_from(constants::SPENDER(), token_dispatcher.contract_address, 42);

    assert_eq!(token_dispatcher.balance_of(constants::SPENDER()), 58);
    assert_eq!(token_dispatcher.allowance(constants::SPENDER(), constants::RECIPIENT()), 0);

    // test event emission
    spy
        .assert_emitted(
            @array![
                (
                    get_contract_address(),
                    Event::Locked(
                        Locked { token: token_dispatcher.contract_address, from: constants::SPENDER(), amount: 42 }
                    )
                )
            ]
        )
}


#[test]
fn test_lock_unlock() {
    let mut spy = spy_events();
    let token_dispatcher = utils::setup_erc20(recipient: constants::OWNER());
    start_cheat_caller_address(token_dispatcher.contract_address, constants::OWNER());

    token_dispatcher.transfer(constants::SPENDER(), 100);

    start_cheat_caller_address(token_dispatcher.contract_address, constants::SPENDER());

    token_dispatcher.approve(constants::RECIPIENT(), 42);
    start_cheat_caller_address(token_dispatcher.contract_address, constants::RECIPIENT());

    let mut escrow: ComponentState = Default::default();

    escrow.lock_from(constants::SPENDER(), token_dispatcher.contract_address, 42);

    start_cheat_caller_address(token_dispatcher.contract_address, get_contract_address());

    token_dispatcher.approve(constants::RECIPIENT(), 42);

    start_cheat_caller_address(token_dispatcher.contract_address, constants::RECIPIENT());
    escrow.unlock_to(constants::SPENDER(), constants::RECIPIENT(), token_dispatcher.contract_address, 42);

    assert_eq!(token_dispatcher.balance_of(constants::SPENDER()), 58);
    assert_eq!(token_dispatcher.balance_of(constants::RECIPIENT()), 42);
    assert_eq!(token_dispatcher.allowance(constants::SPENDER(), constants::RECIPIENT()), 0);
    assert_eq!(escrow.deposits.read((constants::SPENDER(), token_dispatcher.contract_address)), 0);

    // test event emission
    spy
        .assert_emitted(
            @array![
                (
                    get_contract_address(),
                    Event::Locked(
                        Locked { token: token_dispatcher.contract_address, from: constants::SPENDER(), amount: 42 }
                    )
                )
            ]
        );

    spy
        .assert_emitted(
            @array![
                (
                    get_contract_address(),
                    Event::UnLocked(
                        UnLocked {
                            token: token_dispatcher.contract_address,
                            from: constants::SPENDER(),
                            to: constants::RECIPIENT(),
                            amount: 42
                        }
                    )
                )
            ]
        )
}


#[test]
#[should_panic(expected: 'Insufficient deposit balance')]
fn test_lock_unlock_greater_than_balance() {
    let token_dispatcher = utils::setup_erc20(recipient: constants::OWNER());
    start_cheat_caller_address(token_dispatcher.contract_address, constants::OWNER());

    token_dispatcher.transfer(constants::SPENDER(), 1000);

    start_cheat_caller_address(token_dispatcher.contract_address, constants::SPENDER());

    token_dispatcher.approve(constants::RECIPIENT(), 42);
    start_cheat_caller_address(token_dispatcher.contract_address, constants::RECIPIENT());

    let mut escrow: ComponentState = Default::default();

    escrow.lock_from(constants::SPENDER(), token_dispatcher.contract_address, 42);

    start_cheat_caller_address(token_dispatcher.contract_address, get_contract_address());

    token_dispatcher.approve(constants::RECIPIENT(), 42);

    start_cheat_caller_address(token_dispatcher.contract_address, constants::RECIPIENT());
    escrow.unlock_to(constants::SPENDER(), constants::RECIPIENT(), token_dispatcher.contract_address, 420);
}

#[test]
#[should_panic(expected: 'ERC20: insufficient allowance')]
fn test_lock_from_unallowed_caller() {
    let token_dispatcher = utils::setup_erc20(recipient: constants::OWNER());
    start_cheat_caller_address(token_dispatcher.contract_address, constants::OWNER());

    token_dispatcher.transfer(constants::SPENDER(), 100);

    start_cheat_caller_address(token_dispatcher.contract_address, constants::SPENDER());

    token_dispatcher.approve(constants::RECIPIENT(), 42);

    start_cheat_caller_address(token_dispatcher.contract_address, constants::CALLER());

    let mut escrow: ComponentState = Default::default();

    escrow.lock_from(constants::SPENDER(), token_dispatcher.contract_address, 42);
}
