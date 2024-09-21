#[starknet::component]
pub mod RegistryComponent {
    use core::num::traits::Zero;
    use starknet::storage::{Map, StorageMapReadAccess, StorageMapWriteAccess};
    use starknet::{ContractAddress, get_caller_address};
    use zkramp::components::registry::interface::OffchainId;
    use zkramp::components::registry::interface;

    //
    // Storage
    //

    #[storage]
    pub struct Storage {
        pub Registry_registrations: Map::<(ContractAddress, OffchainId), bool>,
    }

    //
    // Errors
    //

    pub mod Errors {
        pub const ZERO_ADDRESS_CALLER: felt252 = 'Caller is the zero address';
    }

    //
    // Registration Event
    //

    #[event]
    #[derive(Drop, Debug, PartialEq, starknet::Event)]
    pub enum Event {
        RegistrationEvent: RegistrationEvent,
    }

    #[derive(Drop, Debug, PartialEq, starknet::Event)]
    pub struct RegistrationEvent {
        #[key]
        pub caller: ContractAddress,
        pub offchain_id: OffchainId,
    }

    //
    // Registry impl
    //

    #[embeddable_as(RegistryImpl)]
    impl Registry<
        TContractState, +HasComponent<TContractState>, +Drop<TContractState>,
    > of interface::IRegistry<ComponentState<TContractState>> {
        fn is_registered(
            self: @ComponentState<TContractState>, contract_address: ContractAddress, offchain_id: OffchainId
        ) -> bool {
            self.Registry_registrations.read((contract_address, offchain_id))
        }

        fn register(ref self: ComponentState<TContractState>, offchain_id: OffchainId) {
            let caller = get_caller_address();

            // verify caller
            assert(caller.is_non_zero(), Errors::ZERO_ADDRESS_CALLER);

            // save registration
            self.Registry_registrations.write((caller, offchain_id), true);

            // emit registration event
            self.emit(RegistrationEvent { caller: caller, offchain_id: offchain_id });
        }
    }
}
