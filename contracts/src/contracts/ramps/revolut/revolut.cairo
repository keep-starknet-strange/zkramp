#[starknet::contract]
pub mod RevolutRamp {
    use core::num::traits::Zero;
    use openzeppelin::access::ownable::OwnableComponent;
    use starknet::storage::{
        Map, StoragePointerReadAccess, StoragePointerWriteAccess, StorageMapReadAccess, StorageMapWriteAccess
    };
    use starknet::{ContractAddress, get_caller_address, get_block_timestamp};
    use zkramp::components::escrow::escrow::EscrowComponent;
    use zkramp::components::registry::interface::{OffchainId, IRegistry};
    use zkramp::components::registry::registry::RegistryComponent;
    use zkramp::contracts::ramps::revolut::interface::{LiquidityKey, IZKRampLiquidity, LiquidityShareRequest, Proof};

    //
    // Components
    //

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
    // Constants
    //

    pub const LOCK_DURATION_STEP: u64 = 900; // 15min
    pub const MINIMUM_LOCK_DURATION: u64 = 3600; // 1h

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
        // (liquidity_key, timestamp) -> amount locked until timestamp is reached
        locked_liquidity_shares: Map::<(LiquidityKey, u64), u256>,
        // offchain_id -> liquidity share request
        liquidity_share_request: Map::<OffchainId, LiquidityShareRequest>,
    }

    //
    // Errors
    //

    pub mod Errors {
        pub const NOT_REGISTERED: felt252 = 'Caller is not registered';
        pub const CALLER_IS_NOT_OWNER: felt252 = 'Caller is not the owner';
        pub const CALLER_IS_OWNER: felt252 = 'Caller is the owner';
        pub const NULL_AMOUNT: felt252 = 'Amount cannot be null';
        pub const UNLOCKED_LIQUIDITY: felt252 = 'Liquidity is unlocked';
        pub const NOT_ENOUGH_LIQUDITY: felt252 = 'Not enough liquidity';
        pub const LOCKED_LIQUIDITY_WITHDRAW: felt252 = 'Liquidity is not available';
        pub const BUSY_OFFCHAIN_ID: felt252 = 'This offchainID is busy';
        pub const LIQUIDITY_SHARE_NOT_AVAILABLE: felt252 = 'Liquidity share not available';
    }

    //
    // Events
    //

    #[event]
    #[derive(Drop, starknet::Event)]
    pub enum Event {
        #[flat]
        OwnableEvent: OwnableComponent::Event,
        #[flat]
        RegistryEvent: RegistryComponent::Event,
        #[flat]
        EscrowEvent: EscrowComponent::Event,
        LiquidityAdded: LiquidityAdded,
        LiquidityLocked: LiquidityLocked,
        LiquidityRetrieved: LiquidityRetrieved,
        LiquidityShareRequested: LiquidityShareRequested,
        LiquidityShareWithdrawn: LiquidityShareWithdrawn,
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

    // Emitted when a liquidity share is requested
    #[derive(Drop, starknet::Event)]
    pub struct LiquidityShareRequested {
        #[key]
        pub liquidity_key: LiquidityKey,
        pub amount: u256,
        pub requestor: ContractAddress,
        pub offchain_id: OffchainId,
        pub expiration_date: u64,
    }

    // Emitted when a liquidity share is withdrawn
    #[derive(Drop, starknet::Event)]
    pub struct LiquidityShareWithdrawn {
        #[key]
        pub liquidity_key: LiquidityKey,
        pub amount: u256,
        pub withdrawer: ContractAddress,
        pub offchain_id: OffchainId,
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

    //
    // ZkRamp Liquidity impl
    //

    #[abi(embed_v0)]
    impl ZKRampLiquidityImpl of IZKRampLiquidity<ContractState> {
        fn all_liquidity(self: @ContractState, liquidity_key: LiquidityKey) -> u256 {
            self.liquidity.read(liquidity_key)
        }

        fn available_liquidity(self: @ContractState, liquidity_key: LiquidityKey) -> u256 {
            if self.locked_liquidity.read(liquidity_key) {
                0
            } else {
                self._get_available_liquidity(:liquidity_key)
            }
        }

        fn liquidity_share_request(self: @ContractState, offchain_id: OffchainId) -> Option<LiquidityShareRequest> {
            let share_request = self.liquidity_share_request.read(offchain_id);

            if share_request.expiration_date > get_block_timestamp() {
                Option::Some(share_request)
            } else {
                Option::None
            }
        }

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
            // asserts amount is non null
            assert(amount.is_non_zero(), Errors::NULL_AMOUNT);

            // get liquidity key
            let liquidity_key = LiquidityKey { owner: caller, offchain_id };

            // Add the liquidity to the contract
            let existing_amount = self.liquidity.read(liquidity_key);
            self.liquidity.write(liquidity_key, existing_amount + amount);

            // unlocks liquidity
            self.locked_liquidity.write(liquidity_key, false);

            // use the escrow to lock the funds
            self.escrow.lock(from: caller, :token, :amount);

            // Emit LiquidityAdded event
            self.emit(LiquidityAdded { liquidity_key, amount });
        }

        /// Makes your liquidity unavailable, in order to retrieve it later.
        fn initiate_liquidity_retrieval(ref self: ContractState, liquidity_key: LiquidityKey) {
            let caller = get_caller_address();

            // asserts liquidity amount is non null
            assert(self.liquidity.read(liquidity_key).is_non_zero(), Errors::NULL_AMOUNT);
            // asserts caller is the liquidity owner
            assert(liquidity_key.owner == caller, Errors::CALLER_IS_NOT_OWNER);

            // locks liquidity
            self.locked_liquidity.write(liquidity_key, true);

            // emits LiquidityLocked event
            self.emit(LiquidityLocked { liquidity_key });
        }

        /// Retrieve liquidity if locked and owned by the caller.
        fn retrieve_liquidity(ref self: ContractState, liquidity_key: LiquidityKey) {
            let caller = get_caller_address();

            // asserts caller is the liquidity owner
            assert(self.locked_liquidity.read(liquidity_key), Errors::UNLOCKED_LIQUIDITY);
            // asserts caller is the liquidity owner
            assert(liquidity_key.owner == caller, Errors::CALLER_IS_NOT_OWNER);

            let token = self.token.read();
            let amount = self.liquidity.read(liquidity_key);

            // use the escrow to unlock the funds
            self.escrow.unlock(from: caller, to: caller, :token, :amount);

            // emits Liquidityretrieved event
            self.emit(LiquidityRetrieved { liquidity_key, amount });
        }

        // If the requested amount is valid according to the available amount,
        // this share of the liquidity becomes unavailable for other users and the on-ramper has a defined period
        // to provide proof of the off-chain transfer in order to withdraw the funds.
        fn initiate_liquidity_withdrawal(
            ref self: ContractState, liquidity_key: LiquidityKey, amount: u256, offchain_id: OffchainId
        ) {
            let caller = get_caller_address();
            let current_timestamp = get_block_timestamp();

            // assert caller is not the liquidity owner
            assert(liquidity_key.owner != caller, Errors::CALLER_IS_OWNER);
            // asserts amount is non null
            assert(amount.is_non_zero(), Errors::NULL_AMOUNT);
            // assert liquidity is unlocked
            assert(!self.locked_liquidity.read(liquidity_key), Errors::LOCKED_LIQUIDITY_WITHDRAW);
            // assert caller registered the offchain ID
            assert(self.registry.is_registered(contract_address: caller, :offchain_id), Errors::NOT_REGISTERED);
            // assert offchain_id is not busy with another withdrawal
            assert(
                self.liquidity_share_request.read(offchain_id).expiration_date <= current_timestamp,
                Errors::BUSY_OFFCHAIN_ID
            );

            // get actually available liquidity
            let available_liquidity_amount = self._get_available_liquidity(:liquidity_key);

            // assert requested amount is valid
            assert(amount <= available_liquidity_amount, Errors::NOT_ENOUGH_LIQUDITY);

            // compute liquidity share locking period
            let expiration_date = self._get_next_timestamp_key(current_timestamp + MINIMUM_LOCK_DURATION);

            // lock liquidity share amount
            let locked_amount = self.locked_liquidity_shares.read((liquidity_key, expiration_date));
            self.locked_liquidity_shares.write((liquidity_key, expiration_date), locked_amount + amount);

            // save share request
            self
                .liquidity_share_request
                .write(
                    offchain_id, LiquidityShareRequest { requestor: caller, liquidity_key, amount, expiration_date }
                );

            // emit event
            self
                .emit(
                    LiquidityShareRequested { liquidity_key, amount, requestor: caller, offchain_id, expiration_date }
                )
        }

        /// If the proof is valid according to the amount the caller requested using
        /// the `initiate_liquidity_withdrawal` method, then the requested portion of the liquidity
        /// is transferred to the caller.
        fn withdraw_liquidity(
            ref self: ContractState, liquidity_key: LiquidityKey, offchain_id: OffchainId, proof: Proof
        ) {
            let caller = get_caller_address();
            let current_timestamp = get_block_timestamp();
            let mut share_request = self.liquidity_share_request.read(offchain_id);
            let token = self.token.read();

            // assert caller has a valid pending withdrawal
            assert(
                share_request.expiration_date > current_timestamp && share_request.requestor == caller,
                Errors::LIQUIDITY_SHARE_NOT_AVAILABLE
            );

            // TODO: verify proof

            // update liquidity amount
            let amount = self.liquidity.read(liquidity_key);
            self.liquidity.write(liquidity_key, amount - share_request.amount);

            // update requested liquidity amount
            let amount = self.locked_liquidity_shares.read((liquidity_key, share_request.expiration_date));
            self
                .locked_liquidity_shares
                .write((liquidity_key, share_request.expiration_date), amount - share_request.amount);

            // invalidate share request
            share_request.expiration_date = 0;
            self.liquidity_share_request.write(offchain_id, share_request);

            // unlock funds
            self.escrow.unlock(from: liquidity_key.owner, to: caller, :token, :amount);

            // emit event
            self.emit(LiquidityShareWithdrawn { liquidity_key, amount, withdrawer: caller, offchain_id })
        }
    }

    //
    // Internals
    //

    #[generate_trait]
    impl InternalImpl of InternalTrait {
        fn _get_available_liquidity(self: @ContractState, liquidity_key: LiquidityKey) -> u256 {
            let mut amount = self.liquidity.read(liquidity_key);
            let current_timestamp = get_block_timestamp();
            let mut key_timestamp = self._get_next_timestamp_key(current_timestamp + MINIMUM_LOCK_DURATION);

            while key_timestamp > current_timestamp {
                amount -= self.locked_liquidity_shares.read((liquidity_key, key_timestamp));
                key_timestamp -= LOCK_DURATION_STEP;
            };

            amount
        }

        fn _get_next_timestamp_key(self: @ContractState, after: u64) -> u64 {
            // minus 1 in order to return `after` if it's already a valid key timestamp.
            after - 1 + LOCK_DURATION_STEP - ((after - 1) % LOCK_DURATION_STEP)
        }
    }
}
