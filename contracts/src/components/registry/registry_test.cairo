use zkramp::components::registry::interface::{IRegistryDispatcher, IRegistryDispatcherTrait};
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
#[should_panic(expected: ('Caller is the zero address', 'ENTRYPOINT_FAILED'))]
fn test_register_from_zero() {
    let registry = setup_contracts();

    registry.register(offchain_id: constants::REVOLUT_ID());
}
