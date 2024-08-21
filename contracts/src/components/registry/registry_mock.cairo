use super::registry::RegistryComponent;

#[starknet::contract]
pub mod RegistryMock {
    use starknet::ContractAddress;
    use starknet::account::Call;
    use zkramp::components::registry::interface::IRegistry;
    use zkramp::components::registry::registry::RegistryComponent;

    component!(path: RegistryComponent, storage: registry, event: RegistryEvent);

    // Registry
    #[abi(embed_v0)]
    impl RegistryImpl = RegistryComponent::RegistryImpl<ContractState>;

    //
    // Storage
    //

    #[storage]
    struct Storage {
        #[substorage(v0)]
        registry: RegistryComponent::Storage,
    }

    //
    // Events
    //

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        #[flat]
        RegistryEvent: RegistryComponent::Event,
    }

    //
    // Constructor
    //

    #[constructor]
    fn constructor(ref self: ContractState) {// Nothing to be done
    }
}

type ComponentState = RegistryComponent::ComponentState<RegistryMock::ContractState>;

fn COMPONENT() -> ComponentState {
    RegistryComponent::component_state_for_testing()
}
