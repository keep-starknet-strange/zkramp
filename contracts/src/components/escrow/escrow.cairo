#[starknet::component]
pub mod EscrowComponent {
    use openzeppelin_token::erc20::interface::{IERC20Dispatcher, IERC20DispatcherTrait};
    use starknet::storage::{Map, StorageMapReadAccess, StorageMapWriteAccess};
    use starknet::{ContractAddress, get_contract_address};
    use zkramp::components::escrow::interface;

    //
    // Storage
    //

    #[storage]
    pub struct Storage {
        // (owner, token) -> amount
        pub deposits: Map::<(ContractAddress, ContractAddress), u256>,
    }

    //
    // Errors
    //

    pub mod Errors {
        pub const INSUFFICIENT_BALANCE: felt252 = 'Insufficient deposit balance';
    }

    //
    // Escrow impl
    //

    #[embeddable_as(EscrowImpl)]
    impl Escrow<
        TContractState, +HasComponent<TContractState>, +Drop<TContractState>,
    > of interface::IEscrow<ComponentState<TContractState>> {
        fn lock(ref self: ComponentState<TContractState>, from: ContractAddress, token: ContractAddress, amount: u256) {
            let erc20_dispatcher = IERC20Dispatcher { contract_address: token };

            // transfers funds to escrow
            erc20_dispatcher.transfer_from(sender: from, recipient: get_contract_address(), :amount);

            // update locked amount
            let locked_amount = self.deposits.read((from, token));
            self.deposits.write((from, token), amount + locked_amount);
        }

        fn unlock(
            ref self: ComponentState<TContractState>,
            from: ContractAddress,
            to: ContractAddress,
            token: ContractAddress,
            amount: u256
        ) {
            let locked_amount = self.deposits.read((from, token));

            // check deposit balance
            assert(locked_amount >= amount, Errors::INSUFFICIENT_BALANCE);

            // transfert of the amount to `to`
            let erc20_dispatcher = IERC20Dispatcher { contract_address: token };

            erc20_dispatcher.transfer(recipient: to, :amount);

            // update locked amount
            self.deposits.write((from, token), locked_amount - amount);
        }
    }
}
