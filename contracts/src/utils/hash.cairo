use core::hash::{HashStateTrait, Hash};

// Care must be taken when using this implementation: Serde of the type T must be safe for hashing.
// This means that no two values of type T have the same serialization.
pub(crate) impl HashSerializable<
    T, S, +Serde<T>, +HashStateTrait<S>, +Drop<T>, +Drop<S>
> of Hash<T, S> {
    fn update_state(mut state: S, value: T) -> S {
        let mut arr = array![];
        Serde::serialize(@value, ref arr);
        state = state.update(arr.len().into());
        while let Option::Some(word) = arr.pop_front() {
            state = state.update(word)
        };

        state
    }
}
