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

    // setup caller
    start_cheat_caller_address(contract_address, constants::CALLER());

    // register
    state.register(offchain_id: constants::REVOLUT_ID());

    // assert state after
    assert!(state.is_registered(constants::CALLER(), constants::REVOLUT_ID()));

    // check on emitted events
    spy
        .assert_emitted(
            @array![
                (
                    contract_address,
                    Event::RegistrationEvent(
                        RegistrationEvent { caller: constants::CALLER(), offchain_id: constants::REVOLUT_ID() }
                    )
                )
            ]
        )
}

// #[test]
fn test_register_twice_same_offchain_id() {
    panic!("Not implemented yet");
}

// #[test]
fn test_register_two_different_offchain_id() {
    panic!("Not implemented yet");
}

// #[test]
fn test_register_same_offchain_id_from_two_different_callers() {
    panic!("Not implemented yet");
}

//
// is_registered
//

// #[test]
fn test_is_registered() {
    panic!("Not implemented yet");
}
