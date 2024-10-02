use snforge_std::{EventSpyAssertionsTrait, spy_events, test_address, start_cheat_caller_address};
use zkramp::components::registry::registry::{RegistryComponent::{Event, RegistrationEvent, RegistryImpl}};
use zkramp::components::registry::registry_mock::{TestingStateDefault, ComponentState};
use zkramp::tests::constants;

fn COMPONENT_STATE() -> ComponentState {
    Default::default()
}

fn setup() -> ComponentState {
    COMPONENT_STATE()
    // no more setup needed here
}

//
// register
//

#[test]
#[should_panic(expected: 'Caller is the zero address')]
fn test_register_from_zero() {
    let mut state = setup();

    state.register(offchain_id: constants::REVOLUT_ID());
}

#[test]
fn test_register() {
    let mut state = setup();
    let mut spy = spy_events();
    let contract_address = test_address();
    let caller = constants::CALLER();
    let offchain_id = constants::REVOLUT_ID();

    // setup caller
    start_cheat_caller_address(contract_address, constants::CALLER());

    // register
    state.register(:offchain_id);

    // assert state after
    assert!(state.is_registered(contract_address: caller, :offchain_id));

    // check on emitted events
    spy
        .assert_emitted(
            @array![
                (
                    contract_address,
                    Event::RegistrationEvent(
                        RegistrationEvent { caller, offchain_id }
                    )
                )
            ]
        );
}

#[test]
fn test_register_twice_same_offchain_id() {
    let mut state = setup();
    let mut spy = spy_events();
    let contract_address = test_address();
    let caller = constants::CALLER();
    let offchain_id = constants::REVOLUT_ID();

    // setup caller
    start_cheat_caller_address(contract_address, caller);

    // double registeration
    state.register(:offchain_id);
    state.register(:offchain_id);

    // assert state after
    assert!(state.is_registered(contract_address: caller, :offchain_id));

    // check on emitted events
    spy
        .assert_emitted(
            @array![
                (
                    contract_address,
                    Event::RegistrationEvent(
                        RegistrationEvent { caller, offchain_id }
                    )
                ),
                (
                    contract_address,
                    Event::RegistrationEvent(
                        RegistrationEvent { caller, offchain_id }
                    )
                )
            ]
        );
}

#[test]
fn test_register_two_different_offchain_id() {
    let mut state = setup();
    let mut spy = spy_events();
    let contract_address = test_address();
    let caller = constants::CALLER();
    let offchain_id1 = constants::REVOLUT_ID();
    let offchain_id2 = constants::REVOLUT_ID2();

    // setup caller
    start_cheat_caller_address(contract_address, caller);

    // registerations
    state.register(offchain_id: offchain_id1);
    state.register(offchain_id: offchain_id2);

    // assert state after
    assert!(state.is_registered(contract_address: caller, offchain_id: offchain_id1));
    assert!(state.is_registered(contract_address: caller, offchain_id: offchain_id2));

    // check on emitted events
    spy
        .assert_emitted(
            @array![
                (
                    contract_address,
                    Event::RegistrationEvent(
                        RegistrationEvent { caller, offchain_id: offchain_id1 }
                    )
                ),
                (
                    contract_address,
                    Event::RegistrationEvent(
                        RegistrationEvent { caller, offchain_id: offchain_id2 }
                    )
                )
            ]
        );
}

#[test]
fn test_register_same_offchain_id_from_two_different_callers() {
    let mut state = setup();
    let mut spy = spy_events();
    let contract_address = test_address();
    let caller1 = constants::CALLER();
    let caller2 = constants::OTHER();
    let offchain_id = constants::REVOLUT_ID();

    // setup caller one and register
    start_cheat_caller_address(contract_address, caller1);
    state.register(:offchain_id);

    // setup caller two and register
    start_cheat_caller_address(contract_address, caller2);
    state.register(:offchain_id);

    // assert state after
    assert!(state.is_registered(contract_address: caller1, :offchain_id));
    assert!(state.is_registered(contract_address: caller2, :offchain_id));

    // check on emitted events
    spy
        .assert_emitted(
            @array![
                (
                    contract_address,
                    Event::RegistrationEvent(
                        RegistrationEvent { caller: caller1, offchain_id }
                    )
                ),
                (
                    contract_address,
                    Event::RegistrationEvent(
                        RegistrationEvent { caller: caller2, offchain_id }
                    )
                )
            ]
        );
}

//
// is_registered
//

#[test]
fn test_is_registered() {
    let mut state = setup();
    let contract_address = test_address();
    let caller = constants::CALLER();
    let offchain_id1 = constants::REVOLUT_ID();
    let offchain_id2 = constants::REVOLUT_ID2();

    assert!(!state.is_registered(contract_address: caller, offchain_id: offchain_id1));
    assert!(!state.is_registered(contract_address: caller, offchain_id: offchain_id2));

    // register
    start_cheat_caller_address(contract_address, constants::CALLER());
    state.register(offchain_id: offchain_id1);

    assert!(state.is_registered(contract_address: caller, offchain_id: offchain_id1));
    assert!(!state.is_registered(contract_address: caller, offchain_id: offchain_id2));

    // register another offchain ID
    start_cheat_caller_address(contract_address, constants::CALLER());
    state.register(offchain_id: offchain_id2);

    assert!(state.is_registered(contract_address: caller, offchain_id: offchain_id1));
    assert!(state.is_registered(contract_address: caller, offchain_id: offchain_id2));
}
