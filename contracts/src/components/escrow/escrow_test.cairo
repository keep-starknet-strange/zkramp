use core::starknet::get_contract_address;

use openzeppelin::presets::interfaces::ERC20UpgradeableABIDispatcherTrait;

use zkramp::components::escrow::escrow::EscrowComponent::EscrowImpl;
use zkramp::components::escrow::escrow_mock::{TestingStateDefault, ComponentState};

use zkramp::tests::constants;
use zkramp::tests::utils;


//
// Externals
//

#[test]
fn test_lock_unlock() {
    let token_dispatcher = utils::setup_erc20(recipient: get_contract_address());

    token_dispatcher.transfer(constants::OWNER(), 100);

    let mut escrow: ComponentState = Default::default();

    escrow.lock_from(constants::OWNER(), token_dispatcher.contract_address, 42);

    escrow
        .unlock_to(constants::OWNER(), constants::CALLER(), token_dispatcher.contract_address, 42);

    assert_eq!(escrow.deposits.read((constants::OWNER(), token_dispatcher.contract_address)), 0);
}
