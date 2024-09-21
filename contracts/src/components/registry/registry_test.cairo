use snforge_std::{EventSpyAssertionsTrait, spy_events, test_address};
use zkramp::components::registry::registry::{RegistryComponent::{Event, RegistrationEvent, RegistryImpl}};
use zkramp::components::registry::registry_mock::{TestingStateDefault, ComponentState};
use zkramp::tests::constants;

//
// register
//

#[test]
#[should_panic(expected: 'Caller is the zero address')]
fn test_register_from_zero() {
    let mut registry: ComponentState = Default::default();

    registry.register(offchain_id: constants::REVOLUT_ID());
}

#[test]
fn test_register() {
    let mut spy = spy_events();
    let mut registry: ComponentState = Default::default();

    registry.register(offchain_id: constants::REVOLUT_ID());

    assert!(registry.is_registered(constants::CALLER(), constants::REVOLUT_ID()));

    spy
        .assert_emitted(
            @array![
                (
                    test_address(),
                    Event::RegistrationEvent(
                        RegistrationEvent { caller: constants::CALLER(), offchain_id: constants::REVOLUT_ID() }
                    )
                )
            ]
        )
}

#[test]
fn test_register_twice_same_offchain_id() {
}

#[test]
fn test_register_two_different_offchain_id() {
}

//
// is_registered
//

#[test]
fn test_is_registered() {
}
