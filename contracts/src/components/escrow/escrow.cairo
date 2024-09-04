#[starknet::component]
pub mod EscrowComponent {
    use openzeppelin_token::erc20::interface::{IERC20Dispatcher, IERC20DispatcherTrait};
    use starknet::ContractAddress;
    use starknet::storage::Map;
    use zkramp::components::escrow::interface;

    //
    // Storage
    //

    #[storage]
    struct Storage {
        // (owner, token) -> amount
        deposits: Map::<(ContractAddress, ContractAddress), u256>,
        // token -> escrow address
        escrow_contract_addresses: Map::<ContractAddress, ContractAddress>,
    }

    //
    // Errors
    //

    pub mod Errors {
        pub const PROOF_OF_DEPOSIT_FAILED: felt252 = 'Proof of deposit failed';
        pub const INSUFFICIENT_BALANCE: felt252 = 'Insufficient deposit balance';
    }

    //
    // Escrow impl
    //

    #[embeddable_as(RegistryImpl)]
    impl Escrow<
        TContractState, +HasComponent<TContractState>, +Drop<TContractState>,
    > of interface::IEscrow<ComponentState<TContractState>> {
        fn lock_from(
            ref self: ComponentState<TContractState>,
            from: ContractAddress,
            token: ContractAddress,
            amount: u256
        ) {
            let erc20_dispatcher = IERC20Dispatcher { contract_address: token };

            let balance = erc20_dispatcher.balance_of(from);

            assert(balance >= amount, Errors::INSUFFICIENT_BALANCE);

            let locked_amount = self.deposits.read((from, token));

            // Retreives escrow address for the token `token``
            let escrow_contract_address = self.escrow_contract_addresses.read(token);

            // Transfers funds to escrow
            transfer_erc20(from, escrow_contract_address, token, amount);

            self.deposits.write((from, token), amount + locked_amount);
        }

        fn unlock_to(
            ref self: ComponentState<TContractState>,
            from: ContractAddress,
            to: ContractAddress,
            token: ContractAddress,
            amount: u256
        ) {
            let escrow_contract_address = self.escrow_contract_addresses.read(token);

            let locked_amount = self.deposits.read((from, token));

            // TODO
            // check for proof of deposit
            assert(true, Errors::PROOF_OF_DEPOSIT_FAILED);

            // check deposit balance
            assert(locked_amount >= amount, Errors::INSUFFICIENT_BALANCE);

            // transfert of the amount `amount` from `from` to `to`
            transfer_erc20(escrow_contract_address, to, token, amount);

            // update locked amount
            self.deposits.write((from, token), locked_amount - amount);
        }
    }

    //
    // Internals
    //

    fn transfer_erc20(
        from: ContractAddress, token: ContractAddress, to: ContractAddress, amount: u256
    ) {
        let erc20_dispatcher = IERC20Dispatcher { contract_address: token };

        erc20_dispatcher.transfer_from(from, to, amount);
    }
}
