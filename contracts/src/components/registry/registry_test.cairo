use core::starknet::contract_address_const;
use starknet::testing::{set_caller_address, set_contract_address};
use zkramp::components::registry::interface::{IRegistryDispatcher, IRegistryDispatcherTrait};
use zkramp::components::registry::registry::{RegistryComponent::{Event, RegistrationEvent},};
use zkramp::components::registry::registry_mock::RegistryMock;
use zkramp::tests::constants;
use zkramp::tests::utils;


/// Deploys the registry mock contract.
fn setup_contracts() -> IRegistryDispatcher {
    // deploy registry
    let registry_contract_address = utils::deploy(
        RegistryMock::TEST_CLASS_HASH, calldata: array![]
    );

    IRegistryDispatcher { contract_address: registry_contract_address }
}

//
// Externals
//

#[test]
fn test_is_registered() {
    set_contract_address(contract_address_const::<'caller'>());
    let registry = setup_contracts();

    registry.register(offchain_id: constants::REVOLUT_ID());

    assert_eq!(
        registry.is_registered(contract_address_const::<'caller'>(), constants::REVOLUT_ID()), true
    );
}

#[test]
fn test_registration_event() {
    set_contract_address(contract_address_const::<'caller'>());
    let registry = setup_contracts();

    registry.register(offchain_id: constants::REVOLUT_ID());

    assert_eq!(
        starknet::testing::pop_log(registry.contract_address),
        Option::Some(
            Event::RegistrationEvent(
                RegistrationEvent {
                    caller: contract_address_const::<'caller'>(),
                    offchain_id: constants::REVOLUT_ID()
                }
            )
        )
    );
}

#[test]
#[should_panic(expected: ('Caller is the zero address', 'ENTRYPOINT_FAILED'))]
fn test_register_from_zero() {
    let registry = setup_contracts();

    registry.register(offchain_id: constants::REVOLUT_ID());
}
