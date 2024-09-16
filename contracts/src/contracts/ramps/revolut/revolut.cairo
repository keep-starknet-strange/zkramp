#[starknet::contract]
pub mod RevolutRamp {
    use core::num::traits::Zero;
    use core::starknet::storage::{StoragePointerReadAccess};
    use openzeppelin::access::ownable::OwnableComponent;
    use starknet::storage::Map;
    use starknet::{ContractAddress, get_caller_address};
    use zkramp::components::escrow::escrow::EscrowComponent;
    use zkramp::components::registry::interface::{OffchainId, IRegistry};
    use zkramp::components::registry::registry::RegistryComponent;
    use zkramp::contracts::ramps::revolut::interface::{LiquidityKey, IZKRampLiquidity};

    component!(path: OwnableComponent, storage: ownable, event: OwnableEvent);
    component!(path: RegistryComponent, storage: registry, event: RegistryEvent);
    component!(path: EscrowComponent, storage: escrow, event: EscrowEvent);

    // Ownable
    #[abi(embed_v0)]
    impl OwnableMixinImpl = OwnableComponent::OwnableMixinImpl<ContractState>;
    impl OwnableInternalImpl = OwnableComponent::InternalImpl<ContractState>;

    // Registry
    #[abi(embed_v0)]
    impl RegistryImpl = RegistryComponent::RegistryImpl<ContractState>;

    // Escrow
    impl EscrowImplImpl = EscrowComponent::EscrowImpl<ContractState>;

    //
    // Storage
    //

    #[storage]
    struct Storage {
        #[substorage(v0)]
        ownable: OwnableComponent::Storage,
        #[substorage(v0)]
        registry: RegistryComponent::Storage,
        #[substorage(v0)]
        escrow: EscrowComponent::Storage,
        token: ContractAddress,
        // liquidity_key -> amount
        liquidity: Map::<LiquidityKey, u256>,
        // liquidity_key -> is_locked
        locked_liquidity: Map::<LiquidityKey, bool>,
    }

    //
    // Errors
    //

    pub mod Errors {
        pub const NOT_REGISTERED: felt252 = 'Caller is not registered';
        pub const INVALID_AMOUNT: felt252 = 'Invalid amount';
        pub const WRONG_CALLER_ADDRESS: felt252 = 'Wrong caller address';
        pub const EMPTY_LIQUIDITY_RETRIEVAL: felt252 = 'Empty liquidity retrieval';
        pub const LOCKED_LIQUIDITY_RETRIEVAL: felt252 = 'Locked liquidity retrieval';
    }

    //
    // Events
    //

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        #[flat]
        OwnableEvent: OwnableComponent::Event,
        #[flat]
        RegistryEvent: RegistryComponent::Event,
        #[flat]
        EscrowEvent: EscrowComponent::Event,
        LiquidityAdded: LiquidityAdded,
        LiquidityLocked: LiquidityLocked,
        LiquidityRetrieved: LiquidityRetrieved,
    }

    // Emitted when liquidity is added
    #[derive(Drop, starknet::Event)]
    pub struct LiquidityAdded {
        #[key]
        pub liquidity_key: LiquidityKey,
        pub amount: u256,
    }

    // Emitted when liquidity is locked
    #[derive(Drop, starknet::Event)]
    pub struct LiquidityLocked {
        #[key]
        pub liquidity_key: LiquidityKey,
    }

    // Emitted when liquidity is retrieved
    #[derive(Drop, starknet::Event)]
    pub struct LiquidityRetrieved {
        #[key]
        pub liquidity_key: LiquidityKey,
        pub amount: u256,
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

    #[abi(embed_v0)]
    impl ZKRampLiquidityImpl of IZKRampLiquidity<ContractState> {
        /// Create a liquidity position by locking an amonunt and asking for
        /// its equivalent on a specific offchain ID.
        ///
        /// If the liquidity position already exists,
        /// just increase the locked amount.
        fn add_liquidity(ref self: ContractState, amount: u256, offchain_id: OffchainId) {
            let caller = get_caller_address();
            let token = self.token.read();

            // assert caller registered the offchain ID
            assert(self.registry.is_registered(contract_address: caller, :offchain_id), Errors::NOT_REGISTERED);
            assert(amount.is_non_zero(), Errors::INVALID_AMOUNT);

            // get liquidity key
            let liquidity_key = LiquidityKey { owner: caller, offchain_id };

            // Add the liquidity to the contract
            let existing_amount = self.liquidity.read(liquidity_key);
            self.liquidity.write(liquidity_key, existing_amount + amount);

            // unlocks liquidity
            self.locked_liquidity.write(liquidity_key, true);

            // use the escrow to lock the funds
            self.escrow.lock(from: caller, :token, :amount);

            // Emit LiquidityAdded event
            self.emit(LiquidityAdded { liquidity_key, amount });
        }

        fn initiate_liquidity_retrieval(ref self: ContractState, liquidity_key: LiquidityKey) {
            let caller = get_caller_address();

            // asserts liquidity amount is non null
            assert(self.liquidity.read(liquidity_key).is_non_zero(), Errors::EMPTY_LIQUIDITY_retrievAL);
            // asserts caller is the liquidity owner
            assert(liquidity_key.owner == caller, Errors::WRONG_CALLER_ADDRESS);

            // locks liquidity
            self.locked_liquidity.write(liquidity_key, true);

            // emits LiquidityLocked event
            self.emit(LiquidityLocked { liquidity_key });
        }

        fn retrieve_liquidity(ref self: ContractState, liquidity_key: LiquidityKey) {
            let caller = get_caller_address();

            let token = self.token.read();
            let amount = self.liquidity.read(liquidity_key);

            // use the escrow to unlock the funds
            self.escrow.unlock(from: caller, to: caller, :token, :amount);

            // emits Liquidityretrieved event
            self.emit(LiquidityRetrieved { liquidity_key, amount });
        }
    }
}
