#[starknet::contract]
pub mod RevolutRamp {
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
        // offchain_id -> address
        offchain_registry: Map::<OffchainId, ContractAddress>,
        next_liquidity_id: felt252,
        // liquidity_id -> amount
        liquidities: Map::<felt252, u256>,
        // address -> liquidity_id
        liquidity_by_address: Map::<ContractAddress, felt252>,
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
    // Constructor
    //

    #[constructor]
    fn constructor(ref self: ContractState, owner: ContractAddress, token: ContractAddress,) {
        // initialize owner
        self.ownable.initializer(:owner);

        self.token.write(token);
        self.next_liquidity_id.write(1);
    }

    #[abi(embed_v0)]
    impl RevolutImpl of zkRampABI<ContractState> {
        fn is_registered(self: @ContractState, contract_address: ContractAddress, offchain_id: OffchainId,) -> bool {
            self.offchain_registry.read(offchain_id) == contract_address
        }

        fn register(ref self: ContractState, offchain_id: OffchainId) {
            let contract_address = get_caller_address();

            // Register the offchain_id with the caller address
            self.offchain_registry.write(offchain_id.clone(), contract_address);

            // Emit Registered event
            self.emit(Registered { offchain_id, contract_address });
        }

        fn add_liquidity(ref self: ContractState, amount: u256, offchain_id: OffchainId,) -> felt252 {
            let address = self.offchain_registry.read(offchain_id.clone());
            let existing_liquidity_id = self.liquidity_by_address.read(address);
            let mut liquidity_id = 0;

            if existing_liquidity_id != 0 {
                liquidity_id = existing_liquidity_id;
            } else {
                // Get the liquidity ID and increment it for the next liquidity
                liquidity_id = self.next_liquidity_id.read();
                self.next_liquidity_id.write(liquidity_id + 1);
            }

            let existing_amount = self.liquidities.read(liquidity_id);

            // Create a new liquidity position
            self.liquidity_by_address.write(address, liquidity_id);
            self.liquidities.write(liquidity_id, existing_amount + amount);

            // Emit LiquidityAdded event
            self.emit(LiquidityAdded { liquidity_id, offchain_id, amount });

            liquidity_id
        }
    }
}
