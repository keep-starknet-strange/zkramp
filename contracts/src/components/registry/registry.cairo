#[starknet::interface]
trait IRegisterContract<ContractState> {
    fn register_user(ref self: ContractState, revolut_ID: felt252);
}

#[starknet::component]
mod RegistryComponent {
    use starknet::storage::Map;
    use starknet::{ContractAddress, get_caller_address};
    use zkramp::components::registry::interface::OffchainId;
    use zkramp::components::registry::interface;

    #[storage]
    struct Storage {
        Registry_registrations: Map::<(ContractAddress, OffchainId), bool>,
    }

    #[embeddable_as(RegistryImpl)]
    impl Registry<
        TContractState, +HasComponent<TContractState>, +Drop<TContractState>,
    > of interface::IRegistry<ComponentState<TContractState>> {
        fn is_registered(
            self: @ComponentState<TContractState>,
            contract_address: ContractAddress,
            offchain_id: OffchainId
        ) -> bool {
            self.Registry_registrations.read((contract_address, offchain_id))
        }

        fn register(ref self: ComponentState<TContractState>, offchain_id: OffchainId) {
            let caller = get_caller_address();

            // TODO: caller a processor to verify the proof of registration

            // save registration
            self.Registry_registrations.write((caller, offchain_id), true)
        }
    }
}
