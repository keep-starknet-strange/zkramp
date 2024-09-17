#[starknet::contract]
pub mod RevolutRamp {
    use core::num::traits::Zero;
    use openzeppelin::access::ownable::OwnableComponent;
    use starknet::storage::Map;
    use starknet::{ContractAddress, get_caller_address};
    use zkramp::components::registry::interface::OffchainId;
    use zkramp::contracts::ramps::revolut::interface::{LiquidityKey, IZKRampLiquidity};
    use zkramp::components::registry::registry::RegistryComponent;

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

        token: ContractAddress,
        // liquidity_key -> amount
        liquidity: Map::<LiquidityKey, u256>,
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

    // Emitted when liquidity is added
    #[derive(Drop, starknet::Event)]
    pub struct LiquidityAdded {
        #[key]
        pub owner: ContractAddress,
        #[key]
        pub offchain_id: OffchainId,
        pub amount: u256,
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        #[flat]
        OwnableEvent: OwnableComponent::Event,
        #[flat]
        RegistryEvent: RegistryComponent::Event,
        
        LiquidityAdded: LiquidityAdded,
    }

    //
    // Constructor
    //

    #[constructor]
    fn constructor(ref self: ContractState, owner: ContractAddress, token: ContractAddress) {
        // initialize owner
        self.ownable.initializer(:owner);

        self.token.write(token);
    }


    #[generate_trait]
    impl Private of PrivateTrait {
        // just a mock
        fn is_registered(self: @ContractState, contract_address: ContractAddress, offchain_id: OffchainId) -> bool {
            true
        }
    }

    #[abi(embed_v0)]
    impl ZKRampLiquidityImpl of IZKRampLiquidity<ContractState> {
        /// Create a liquidity position by locking an amonunt and asking for
        /// its equivalent on a specific offchain ID.
        ///
        /// If the liquidity position already exists,
        /// just increase the locked amount.
        fn add_liquidity(ref self: ContractState, amount: u256, offchain_id: OffchainId) {
            let caller = get_caller_address();

            // assert caller registered the offchain ID
            assert(self.is_registered(contract_address: caller, :offchain_id), Errors::NOT_REGISTERED);
            assert(amount.is_non_zero(), Errors::INVALID_AMOUNT);

            // get liquidity key
            let liquidity_key = LiquidityKey { owner: caller, offchain_id };

            // Add the liquidity to the contract
            let existing_amount = self.liquidity.read(liquidity_key);
            self.liquidity.write(liquidity_key, existing_amount + amount);

            // Emit LiquidityAdded event
            self.emit(LiquidityAdded { owner: caller, offchain_id, amount });
        }
    }
}
