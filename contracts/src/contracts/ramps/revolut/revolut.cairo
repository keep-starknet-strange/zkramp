#[starknet::contract]
pub mod RevolutRamp {
    use core::poseidon::PoseidonTrait;
    use openzeppelin::access::ownable::OwnableComponent;
    use starknet::storage::Map;
    use starknet::{ContractAddress, get_caller_address};
    use zkramp::components::registry::interface::OffchainId;
    use zkramp::contracts::ramps::revolut::interface::zkRampABI;

    component!(path: OwnableComponent, storage: ownable, event: OwnableEvent);

    // Ownable
    #[abi(embed_v0)]
    impl OwnableMixinImpl = OwnableComponent::OwnableMixinImpl<ContractState>;
    impl OwnableInternalImpl = OwnableComponent::InternalImpl<ContractState>;

    //
    // Storage
    //

    #[storage]
    struct Storage {
        #[substorage(v0)]
        ownable: OwnableComponent::Storage,
        token: ContractAddress,
        // liquidity_id -> amount
        liquidity: Map::<felt252, u256>,
    }

    //
    // Errors
    //

    pub mod Errors {
        pub const NOT_REGISTERED: felt252 = 'Caller is not registered';
        pub const INVALID_AMOUNT: felt252 = 'Invalid amount';
    }

    //
    // Events
    //

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        #[flat]
        OwnableEvent: OwnableComponent::Event,
        LiquidityAdded: LiquidityAdded,
        Registered: Registered,
    }

    // Emitted when liquidity is added
    #[derive(Drop, starknet::Event)]
    pub struct LiquidityAdded {
        #[key]
        pub liquidity_id: felt252,
        #[key]
        pub offchain_id: OffchainId,
        pub amount: u256,
    }

    // Emitted when a new address is linked to an offchain ID
    #[derive(Drop, starknet::Event)]
    pub struct Registered {
        #[key]
        pub offchain_id: OffchainId,
        #[key]
        pub contract_address: ContractAddress,
    }

    //
    // Structs
    //

    #[derive(Drop, Hash)]
    pub struct LiquidityIdHash {
        address: ContractAddress,
        offchain_id: OffchainId,
    }

    //
    // Constructor
    //

    #[constructor]
    fn constructor(ref self: ContractState, owner: ContractAddress, token: ContractAddress,) {
        // initialize owner
        self.ownable.initializer(:owner);

        self.token.write(token);
    }

    #[abi(embed_v0)]
    impl RevolutImpl of zkRampABI<ContractState> {
        fn is_registered(
            self: @ContractState, contract_address: ContractAddress, offchain_id: OffchainId,
        ) -> bool {
            true
        }

        fn add_liquidity(
            ref self: ContractState, amount: u256, offchain_id: OffchainId,
        ) -> felt252 {
            let caller = get_caller_address();

            assert(self.is_registered(self, caller, offchain_id), Errors::NOT_REGISTERED);
            assert(amount.is_not_zero(), Errors::INVALID_AMOUNT);

            // Get the liquidity ID by hashing the offchain ID and the caller's address
            let liquidity_id = PoseidonTrait::new()
                .update_with(LiquidityIdHash { address: caller, offchain_id })
                .finalize();

            // Add the liquidity to the contract
            let existing_amount = self.liquidity.read(liquidity_id);
            self.liquidity.write(liquidity_id, existing_amount + amount);

            // Emit LiquidityAdded event
            self.emit(LiquidityAdded { liquidity_id, offchain_id, amount });

            liquidity_id
        }
    }
}
