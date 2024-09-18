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
    use zkramp::contracts::ramps::revolut::interface::{
        LiquidityKey, LiquidityShareRequest, LiquidityShareRequestStatus, IZKRampLiquidity
    };

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
        // request_id -> LiquidityShareRequest
        liquidity_share_requests: Map::<felt252, LiquidityShareRequest>,
        
        share_request_counter: felt252,
    }

    //
    // Errors
    //

    pub mod Errors {
        pub const NOT_REGISTERED: felt252 = 'Caller is not registered';
        pub const INVALID_AMOUNT: felt252 = 'Invalid amount';
        pub const WRONG_CALLER_ADDRESS: felt252 = 'Wrong caller address';
        pub const EMPTY_LIQUIDITY_RETRIEVAL: felt252 = 'Empty liquidity retrieval';
        pub const UNLOCKED_LIQUIDITY_RETRIEVAL: felt252 = 'Unlocked liquidity retrieval';
        pub const INVALID_REQUEST_AMOUNT: felt252 = 'Invalid request amount';
        pub const REQUEST_NOT_FOUND: felt252 = 'Request not found';
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
        LiquidityShareRequested: LiquidityShareRequested,
        LiquidityShareAccepted: LiquidityShareAccepted,
        LiquidityShareRejected: LiquidityShareRejected,
        LiquidityShareCancelled: LiquidityShareCancelled,
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
        pub request_id: felt252,
        pub liquidity_key: LiquidityKey,
        pub amount: u256,
    }

    // Emitted when a liquidity share request is accepted
    #[derive(Drop, starknet::Event)]
    pub struct LiquidityShareAccepted {
        #[key]
        pub request_id: felt252,
        pub liquidity_key: LiquidityKey,
        pub amount: u256,
    }

    // Emitted when a liquidity share request is rejected
    #[derive(Drop, starknet::Event)]
    pub struct LiquidityShareRejected {
        #[key]
        pub request_id: felt252,
        pub liquidity_key: LiquidityKey,
        pub amount: u256,
    }

    // Emitted when a liquidity share request is cancelled
    #[derive(Drop, starknet::Event)]
    pub struct LiquidityShareCancelled {
        #[key]
        pub request_id: felt252,
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
            assert(
                self.registry.is_registered(contract_address: caller, :offchain_id),
                Errors::NOT_REGISTERED
            );
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
            assert(
                self.liquidity.read(liquidity_key).is_non_zero(), Errors::EMPTY_LIQUIDITY_RETRIEVAL
            );
            // asserts caller is the liquidity owner
            assert(liquidity_key.owner == caller, Errors::WRONG_CALLER_ADDRESS);

            // locks liquidity
            self.locked_liquidity.write(liquidity_key, true);

            // emits LiquidityLocked event
            self.emit(LiquidityLocked { liquidity_key });
        }

        fn retrieve_liquidity(ref self: ContractState, liquidity_key: LiquidityKey) {
            let caller = get_caller_address();

            // asserts caller is the liquidity owner
            assert(self.locked_liquidity.read(liquidity_key), Errors::UNLOCKED_LIQUIDITY_RETRIEVAL);
            // asserts caller is the liquidity owner
            assert(liquidity_key.owner == caller, Errors::WRONG_CALLER_ADDRESS);

            let token = self.token.read();
            let amount = self.liquidity.read(liquidity_key);

            // use the escrow to unlock the funds
            self.escrow.unlock(from: caller, to: caller, :token, :amount);

            // emits Liquidityretrieved event
            self.emit(LiquidityRetrieved { liquidity_key, amount });
        }

        /// Request a liquidity share from the liquidity owner.
        fn request_liquidity_share(
            ref self: ContractState, liquidity_key: LiquidityKey, amount: u256
        ) {
            assert(amount.is_non_zero(), Errors::INVALID_REQUEST_AMOUNT);
            let caller = get_caller_address();

            let request_id = self.share_request_counter.read() + 1;
            self.share_request_counter.write(request_id);

            let request = LiquidityShareRequest { requestor: caller, liquidity_key, amount, status: LiquidityShareRequestStatus::Pending };
            self.liquidity_share_requests.write(request_id, request);

            // emits LiquidityShareRequested event
            self.emit(LiquidityShareRequested { request_id, liquidity_key, amount });
        }

        /// Accept a liquidity share request.
        fn accept_liquidity_share_request(ref self: ContractState, request_id: felt252) {
            let caller = get_caller_address();
            let request = self.liquidity_share_requests.read(request_id);
            assert(request.liquidity_key.owner == caller, Errors::WRONG_CALLER_ADDRESS);

            let token = self.token.read();
            let amount = request.amount;

            // Transfer the liquidity share to the requestor
            self.escrow.unlock(
                from: caller,
                to: request.requestor,
                :token,
                :amount
            );

            // accept the request
            let updated_request = LiquidityShareRequest {
                status: LiquidityShareRequestStatus::Accepted,
                ..request 
            };
            self.liquidity_share_requests.write(request_id, updated_request);

            // reject the request
            let updated_request = LiquidityShareRequest {
                status: LiquidityShareRequestStatus::Rejected,
                ..request 
            };
            self.liquidity_share_requests.write(request_id, request);

            // Emit LiquidityShareAccepted event
            self.emit(LiquidityShareAccepted {
                request_id,
                liquidity_key: request.liquidity_key,
                amount
            });
        }

        /// Reject a liquidity share request.
        fn reject_liquidity_share_request(ref self: ContractState, request_id: felt252) {
            let caller = get_caller_address();
            let request = self.liquidity_share_requests.read(request_id);
            assert(request.liquidity_key.owner == caller, Errors::WRONG_CALLER_ADDRESS);

            // reject the request
            let updated_request = LiquidityShareRequest {
                status: LiquidityShareRequestStatus::Rejected,
                ..request 
            };
            self.liquidity_share_requests.write(request_id, updated_request);

            // Emit LiquidityShareRejected event
            self.emit(LiquidityShareRejected {
                request_id,
                liquidity_key: request.liquidity_key,
                amount: request.amount
            }); 
        }

        /// Cancel a liquidity share request.
        fn cancel_liquidity_share_request(ref self: ContractState, request_id: felt252) {
            let caller = get_caller_address();
            let request = self.liquidity_share_requests.read(request_id);
            assert(request.requestor == caller, Errors::WRONG_CALLER_ADDRESS);

            // cancel the request
            let updated_request = LiquidityShareRequest {
                status: LiquidityShareRequestStatus::Cancelled,
                ..request
            };
            self.liquidity_share_requests.write(request_id, updated_request);

            // Emit LiquidityShareCancelled event
            self.emit(LiquidityShareCancelled {
                request_id,
                liquidity_key: request.liquidity_key,
                amount: request.amount
            }); 
        }
    }
}
