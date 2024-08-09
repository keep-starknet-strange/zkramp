#[starknet::interface]
trait IRegisterContract<ContractState> {
    fn register_user(ref self: ContractState, revolut_ID: felt252);
}

#[starknet::contract]
mod RegisterContract {
    use starknet::{ContractAddress, get_caller_address};

    #[storage]
    struct Storage {
        register_revolutID: LegacyMap::<ContractAddress, felt252>,
    }

    #[abi(embed_v0)]
    impl RegisterContract of super::IRegisterContract<ContractState> {
        fn register_user(ref self: ContractState, revolut_ID: felt252) {
            let caller_address = get_caller_address();
            assert(self.register_revolutID.read(caller_address) != 0, 'already registered');
            self.register_revolutID.write(caller_address, revolut_ID);
        }
    }
}
