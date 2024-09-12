use starknet::ContractAddress;
use zkramp::components::registry::interface::OffchainId;

#[derive(Drop, Serde)]
struct Proof {
    foo: felt252
}

#[starknet::interface]
trait zkRampABI<TState> {
    // check if a contract address is linked to an offchain ID
    fn is_registered(self: @TState, contract_address: ContractAddress, offchain_id: OffchainId) -> bool;

    // link an address to an offchain ID
    fn register(ref self: TState, offchain_id: OffchainId);

    // create a liquidity position by locking an amonunt and asking for
    // its equivalent on a specific offchain ID.
    //
    // If the liquidity position already exists,
    // just increase the locked amount.
    //
    // Returns the ID of the position.
    fn add_liquidity(ref self: TState, amount: u256, offchain_id: OffchainId) -> felt252;

    // Makes your liquidity unavailable.
    //
    // The retrieval of liquidity will be possible once the entire
    // locked amount is no longer involved in an on-ramp process
    // by other users.
    fn initiate_liquidity_retrieval(ref self: TState, liquidity_id: felt252);

    // Retrieve liquidity if owned by the caller.
    fn retrieve_liquidity(ref self: TState, liquidity_id: felt252);

    // If the available amount is valid according to the requested amount,
    // this share of the liquidity becomes unavailable and the on-ramp has a defined period
    // to provide proof of the off-chain transfer in order to withdraw the funds.
    fn initiate_liquidity_withdrawal(ref self: TState, liquidity_id: felt252, amount: u256);

    // If the proof is valid according to the funds the caller requested using
    // the `withdraw_liquidity` method, then the requested portion of the liquidity
    // is transferred to the caller.
    fn withdraw_liquidity(ref self: TState, liquidity_id: felt252, proof: Proof);
}
