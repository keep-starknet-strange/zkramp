use core::starknet::{ContractAddress, contract_address_const};
use zkramp::components::registry::interface::OffchainId;

pub fn REVTAG() -> ByteArray {
    "my wonderfull, incredible but also very long, revtag"
}

pub fn REVOLUT_ID() -> OffchainId {
    OffchainId::Revolut(REVTAG())
}

pub fn CALLER() -> ContractAddress {
    contract_address_const::<'caller'>()
}
