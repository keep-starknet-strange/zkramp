#[starknet::component]
pub mod TLSProcessorComponent {
    use core::num::traits::zero::Zero;
    use zkramp::components::processors::tls::interface;
    use zkramp::contracts::nullifier_registry::interface::{NullifierRegistryABIDispatcher, NullifierRegistryABIDispatcherTrait};
    use openzeppelin::access::ownable::OwnableComponent;
    use openzeppelin::access::ownable::ownable::OwnableComponent::InternalTrait as OwnableInternalTrait;
    use starknet::{ContractAddress, get_caller_address};

    //
    // Storage
    //

    #[storage]
    struct Storage {
        TLSProcessor_ramp_address: ContractAddress,
        TLSProcessor_enpoint: ByteArray,
        TLSProcessor_host: ByteArray,
        TLSProcessor_nullifier_registry: NullifierRegistryABIDispatcher,
        TLSProcessor_timestamp_buffer: felt252,
    }

    //
    // Errors
    //

    pub mod Errors {
        pub const NOT_RAMP: felt252 = 'Caller is not the ramp contract';
        pub const ZERO_ADDRESS_CALLER: felt252 = 'Caller is the zero address';
        pub const BAD_ENDPOINT: felt252 = 'Endpoint does not match';
        pub const BAD_HOST: felt252 = 'Host does not match';
        pub const USED_NULLIFIER: felt252 = 'Nullifier has already been used';
    }

    //
    // TLSProcessor impl
    //

    #[embeddable_as(TLSProcessorImpl)]
    impl TLSProcessor<
        TContractState,
        +HasComponent<TContractState>,
        +Drop<TContractState>,
        impl Ownable: OwnableComponent::HasComponent<TContractState>
    > of interface::ITLSProcessor<ComponentState<TContractState>> {
        /// @notice ONLY OWNER: Sets the timestamp buffer for validated TLS calls. This is the amount of time in seconds
        /// that the timestamp can be off by and still be considered valid. Necessary to build in flexibility with L2
        /// timestamps.
        ///
        /// @param timestamp_buffer    The timestamp buffer for validated TLS calls
        ///
        fn set_timestamp_buffer(
            ref self: ComponentState<TContractState>, timestamp_buffer: felt252
        ) {
            // assert only owner
            let mut ownable_component = get_dep_component!(@self, Ownable);
            ownable_component.assert_only_owner();

            // modify timestamp buffer
            self.TLSProcessor_timestamp_buffer.write(timestamp_buffer);
        }
    }

    //
    // Internals
    //

    #[generate_trait]
    pub impl InternalImpl<
        TContractState, +Drop<TContractState>, +HasComponent<TContractState>,
    > of InternalTrait<TContractState> {
        fn initializer(
            ref self: ComponentState<TContractState>,
            ramp_address: ContractAddress,
            nullifier_registry: NullifierRegistryABIDispatcher,
            timestamp_buffer: felt252,
            enpoint: ByteArray,
            host: ByteArray
        ) {
            self.TLSProcessor_ramp_address.write(ramp_address);
            self.TLSProcessor_nullifier_registry.write(nullifier_registry);
            self.TLSProcessor_timestamp_buffer.write(timestamp_buffer);
            self.TLSProcessor_enpoint.write(enpoint);
            self.TLSProcessor_host.write(host);
        }

        /// Panics if called by any contract other than the ramp contract. Use this
        /// to restrict access to certain functions to the ramp contract.
        fn assert_only_ramp(self: @ComponentState<TContractState>) {
            let ramp = self.TLSProcessor_ramp_address.read();
            let caller = get_caller_address();
            assert(caller.is_non_zero(), Errors::ZERO_ADDRESS_CALLER);
            assert(caller == ramp, Errors::NOT_RAMP);
        }

        fn _validate_TLS_endpoint(self: @ComponentState<TContractState>, expected_endpoint: ByteArray, endpoint: ByteArray) {
            assert(expected_endpoint == endpoint, Errors::BAD_ENDPOINT);
        }

        fn _validate_TLS_host(self: @ComponentState<TContractState>, expected_host: ByteArray, host: ByteArray) {
            assert(expected_host == host, Errors::BAD_HOST);
        }

        fn _validate_and_add_nullifier(ref self: ComponentState<TContractState>, nullifier: u256) {
            let nullifier_registry = self.TLSProcessor_nullifier_registry.read();

            assert(!nullifier_registry.is_nullified(:nullifier), Errors::USED_NULLIFIER);
            nullifier_registry.add_nullifier(:nullifier);
        }

        fn _validate_signature(self: @ComponentState<TContractState>, ) {
            // TODO: verifiy signature, can we use SNIP-12?
        }
    }
}
