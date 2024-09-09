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

pub fn OWNER() -> ContractAddress {
    contract_address_const::<'owner'>()
}

pub const SUPPLY: u256 = 1_000_000_000_000_000_000; // 1 ETH


pub fn NAME() -> ByteArray {
    "NAME"
}

pub fn SYMBOL() -> ByteArray {
    "SYMBOL"
}
