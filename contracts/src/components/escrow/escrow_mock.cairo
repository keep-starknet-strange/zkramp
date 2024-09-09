use super::escrow::EscrowComponent;

#[starknet::contract]
pub mod EscrowMock {
    use starknet::ContractAddress;
    use starknet::account::Call;
    use zkramp::components::escrow::escrow::EscrowComponent;
    use zkramp::components::escrow::interface::IEscrow;

    component!(path: EscrowComponent, storage: escrow, event: EscrowEvent);

    // Escrow
    #[abi(embed_v0)]
    impl EscrowImpl = EscrowComponent::EscrowImpl<ContractState>;

    //
    // Storage
    //

    #[storage]
    struct Storage {
        #[substorage(v0)]
        escrow: EscrowComponent::Storage,
    }

    //
    // Events
    //

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        #[flat]
        EscrowEvent: EscrowComponent::Event,
    }

    //
    // Constructor
    //

    #[constructor]
    fn constructor(ref self: ContractState) { // Nothing to be done
    }
}

pub type ComponentState = EscrowComponent::ComponentState<EscrowMock::ContractState>;

pub impl TestingStateDefault of Default<ComponentState> {
    fn default() -> ComponentState {
        EscrowComponent::component_state_for_testing()
    }
}
