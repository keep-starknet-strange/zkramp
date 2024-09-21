use core::starknet::{ContractAddress, contract_address_const};
use zkramp::components::registry::interface::OffchainId;

const REVTAG: felt252 = 'just a random revtag hash';

pub fn REVOLUT_ID() -> OffchainId {
    OffchainId::Revolut(REVTAG)
}

pub fn CALLER() -> ContractAddress {
    contract_address_const::<'caller'>()
}

pub fn SPENDER() -> ContractAddress {
    contract_address_const::<'spender'>()
}

pub fn RECIPIENT() -> ContractAddress {
    contract_address_const::<'recipient'>()
}

pub fn OWNER() -> ContractAddress {
    contract_address_const::<'owner'>()
}

pub fn OTHER() -> ContractAddress {
    contract_address_const::<'other'>()
}

pub const SUPPLY: u256 = 1_000_000_000_000_000_000; // 1 ETH


pub fn NAME() -> ByteArray {
    "NAME"
}

pub fn SYMBOL() -> ByteArray {
    "SYMBOL"
}
