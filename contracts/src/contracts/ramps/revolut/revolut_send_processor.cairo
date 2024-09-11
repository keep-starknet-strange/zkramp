#[starknet::contract]
pub mod RevolutSendProcessor {
    use openzeppelin::access::ownable::OwnableComponent;
    use starknet::ContractAddress;
    use zkramp::components::processors::TLSProcessorComponent;
    use zkramp::contracts::nullifier_registry::interface::INullifierRegistryDispatcher;

    component!(path: TLSProcessorComponent, storage: tls_processor, event: TLSProcessorEvent);
    component!(path: OwnableComponent, storage: ownable, event: OwnableEvent);

    // TLS Processor
    impl TLSProcessorInternalImpl = TLSProcessorComponent::InternalImpl<ContractState>;
    impl OwnableInternalImpl = OwnableComponent::InternalImpl<ContractState>;

    // Ownable Mixin
    #[abi(embed_v0)]
    impl OwnableMixinImpl = OwnableComponent::OwnableMixinImpl<ContractState>;

    //
    // Storage
    //

    #[storage]
    struct Storage {
        #[substorage(v0)]
        tls_processor: TLSProcessorComponent::Storage,
        #[substorage(v0)]
        ownable: OwnableComponent::Storage,
    }

    //
    // Events
    //

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        #[flat]
        TLSProcessorEvent: TLSProcessorComponent::Event,
        #[flat]
        OwnableEvent: OwnableComponent::Event,
    }

    //
    // Constructor
    //

    #[constructor]
    fn constructor(
        ref self: ContractState,
        owner: ContractAddress,
        ramp_address: ContractAddress,
        nullifier_registry: INullifierRegistryDispatcher,
        timestamp_buffer: felt252,
        enpoint: ByteArray,
        host: ByteArray,
    ) {
        // initialize owner
        self.ownable.initializer(:owner);

        // initialize TLS processor
        self
            .tls_processor
            .initializer(:ramp_address, :nullifier_registry, :timestamp_buffer, :enpoint, :host);
    }
}
