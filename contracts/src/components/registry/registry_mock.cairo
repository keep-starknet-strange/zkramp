use super::registry::RegistryComponent;

#[starknet::contract]
pub mod RegistryMock {
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
    fn constructor(ref self: ContractState) { // Nothing to be done
    }
}

pub type ComponentState = RegistryComponent::ComponentState<RegistryMock::ContractState>;

pub impl TestingStateDefault of Default<ComponentState> {
    fn default() -> ComponentState {
        RegistryComponent::component_state_for_testing()
    }
}
