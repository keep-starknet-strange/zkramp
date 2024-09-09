use core::starknet::ContractAddress;
use snforge_std::{start_cheat_caller_address, EventSpyAssertionsTrait, spy_events, test_address};
use zkramp::components::registry::registry::{
    RegistryComponent::{Event, RegistrationEvent, RegistryImpl}
};
use zkramp::components::registry::registry_mock::{TestingStateDefault, ComponentState};
use zkramp::tests::constants;

//
// Externals
//

#[test]
fn test_is_registered() {
    let test_address: ContractAddress = test_address();

    start_cheat_caller_address(test_address, constants::CALLER());

    let mut registry: ComponentState = Default::default();

    registry.register(offchain_id: constants::REVOLUT_ID());

    assert_eq!(registry.is_registered(constants::CALLER(), constants::REVOLUT_ID()), true);
}

#[test]
fn test_registration_event() {
    let test_address: ContractAddress = test_address();
    let mut spy = spy_events();

    start_cheat_caller_address(test_address, constants::CALLER());

    let mut registry: ComponentState = Default::default();

    registry.register(offchain_id: constants::REVOLUT_ID());

    spy
        .assert_emitted(
            @array![
                (
                    test_address,
                    Event::RegistrationEvent(
                        RegistrationEvent {
                            caller: constants::CALLER(), offchain_id: constants::REVOLUT_ID()
                        }
                    )
                )
            ]
        )
}

#[test]
#[should_panic(expected: 'Caller is the zero address')]
fn test_register_from_zero() {
    let mut registry: ComponentState = Default::default();

    registry.register(offchain_id: constants::REVOLUT_ID());
}
