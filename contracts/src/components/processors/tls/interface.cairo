#[starknet::interface]
pub trait ITLSProcessor<TState> {
    fn set_timestamp_buffer(ref self: TState, timestamp_buffer: felt252);
}
