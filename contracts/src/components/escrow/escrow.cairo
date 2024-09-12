#[starknet::component]
pub mod EscrowComponent {
    use openzeppelin_token::erc20::interface::{IERC20Dispatcher, IERC20DispatcherTrait};
    use starknet::storage::Map;
    use starknet::{ContractAddress, get_contract_address};
    use zkramp::components::escrow::interface;

    //
    // Storage
    //

    #[storage]
    struct Storage {
        // (owner, token) -> amount
        deposits: Map::<(ContractAddress, ContractAddress), u256>,
    }

    //
    // Errors
    //

    pub mod Errors {
        pub const PROOF_OF_DEPOSIT_FAILED: felt252 = 'Proof of deposit failed';
        pub const INSUFFICIENT_BALANCE: felt252 = 'Insufficient deposit balance';
    }

    //
    //  EVENTS
    //
    #[event]
    #[derive(Drop, starknet::Event)]
    pub enum Event {
        Locked: Locked,
        UnLocked: UnLocked
    }

    /// Emitted when the escrow is locked
    #[derive(Drop, starknet::Event)]
    pub struct Locked {
        #[key]
        pub token: ContractAddress,
        pub from: ContractAddress,
        pub amount: u256,
    }

    /// Emitted when the escrow is unlocked
    #[derive(Drop, starknet::Event)]
    pub struct UnLocked {
        #[key]
        pub token: ContractAddress,
        pub from: ContractAddress,
        pub to: ContractAddress,
        pub amount: u256,
    }

    //
    // Escrow impl
    //

    #[embeddable_as(EscrowImpl)]
    impl Escrow<
        TContractState, +HasComponent<TContractState>, +Drop<TContractState>,
    > of interface::IEscrow<ComponentState<TContractState>> {
        fn lock_from(
            ref self: ComponentState<TContractState>, from: ContractAddress, token: ContractAddress, amount: u256
        ) {
            let locked_amount = self.deposits.read((from, token));

            // transfers funds to escrow
            let erc20_dispatcher = IERC20Dispatcher { contract_address: token };

            erc20_dispatcher.transfer_from(from, get_contract_address(), amount);

            self.deposits.write((from, token), amount + locked_amount);

            // emit event
            self.emit(Locked { token, from, amount });
        }

        fn unlock_to(
            ref self: ComponentState<TContractState>,
            from: ContractAddress,
            to: ContractAddress,
            token: ContractAddress,
            amount: u256
        ) {
            let locked_amount = self.deposits.read((from, token));

            // TODO
            // check for proof of deposit
            assert(true, Errors::PROOF_OF_DEPOSIT_FAILED);

            // check deposit balance
            assert(locked_amount >= amount, Errors::INSUFFICIENT_BALANCE);

            // transfert of the amount to `to`
            let erc20_dispatcher = IERC20Dispatcher { contract_address: token };

            erc20_dispatcher.transfer_from(get_contract_address(), to, amount);

            // update locked amount
            self.deposits.write((from, token), locked_amount - amount);
            // emit event
            self.emit(UnLocked { token, from, to, amount });
        }
    }
}
