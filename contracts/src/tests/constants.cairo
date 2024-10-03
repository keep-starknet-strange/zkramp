use core::starknet::{ContractAddress, contract_address_const};
use zkramp::components::registry::interface::OffchainId;
use zkramp::contracts::ramps::revolut::interface::Proof;

const REVTAG: felt252 = 'just a random revtag hash';
const REVTAG_TWO: felt252 = 'just another random revtag hash';

const REVTAG2: felt252 = 'just a 2nd random revtag hash';

const REVTAG3: felt252 = 'just a 3rd random revtag hash';

pub fn REVOLUT_ID() -> OffchainId {
    OffchainId::Revolut(REVTAG)
}

pub fn REVOLUT_ID2() -> OffchainId {
    OffchainId::Revolut(REVTAG2)
}

pub fn REVOLUT_ID3() -> OffchainId {
    OffchainId::Revolut(REVTAG3)
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

pub fn OTHER2() -> ContractAddress {
    contract_address_const::<'other2'>()
}

pub const SUPPLY: u256 = 1_000_000_000_000_000_000; // 1 ETH


pub fn NAME() -> ByteArray {
    "NAME"
}

pub fn SYMBOL() -> ByteArray {
    "SYMBOL"
}

pub fn PROOF() -> Proof {
    Proof { foo: 0 }
}
