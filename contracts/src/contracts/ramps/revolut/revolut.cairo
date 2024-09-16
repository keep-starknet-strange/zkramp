#[starknet::contract]
pub mod RevolutRamp {
    use openzeppelin::access::ownable::OwnableComponent;
    use starknet::ContractAddress;
    use zkramp::components::registry::registry::RegistryComponent;
    use zkramp::components::registry::interface::OffchainId;

    component!(path: OwnableComponent, storage: ownable, event: OwnableEvent);
    component!(path: RegistryComponent, storage: registry, event: RegistryEvent);

    // Ownable
    #[abi(embed_v0)]
    impl OwnableMixinImpl = OwnableComponent::OwnableMixinImpl<ContractState>;
    impl OwnableInternalImpl = OwnableComponent::InternalImpl<ContractState>;

    
    // Registry
    #[abi(embed_v0)]
    impl RegistryImpl = RegistryComponent::RegistryImpl<ContractState>;

    //
    // Storage
    //

    #[storage]
    struct Storage {
        #[substorage(v0)]
        ownable: OwnableComponent::Storage,
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
        OwnableEvent: OwnableComponent::Event,
        #[flat]
        RegistryEvent: RegistryComponent::Event,
    }

    //
    // Constructor
    //

    #[constructor]
    fn constructor(ref self: ContractState, owner: ContractAddress,) {
        // initialize owner
        self.ownable.initializer(:owner);
    }
}
