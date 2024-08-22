#[starknet::contract]
pub mod NullifierRegistry {
    use starknet::{
        ContractAddress, get_caller_address, get_block_timestamp,
        storage::{Map, StorageMapReadAccess, StorageMapWriteAccess}
    };
    use zkramp::contracts::nullifier_registry::interface::{
        INullifierRegistry, INullifierRegistryDispatcher, INullifierRegistryDispatcherTrait
    };

    #[storage]
    pub struct Storage {
        writers: Map<u64, ContractAddress>,
        writers_count: u64,
        is_nullified: Map<u256, bool>,
        is_writers: Map<ContractAddress, bool>
    }


    #[event]
    #[derive(Drop, starknet::Event)]
    pub enum Event {
        NullifierAdded: NullifierAdded,
        WriterAdded: WriterAdded,
        WriterRemoved: WriterRemoved
    }

    /// @notice Emitted when the account is locked
    /// @param account tokenbound account who's lock function was triggered
    /// @param locked_at timestamp at which the lock function was triggered
    /// @param lock_until time duration for which the account remains locked in second
    #[derive(Drop, starknet::Event)]
    pub struct NullifierAdded {
        #[key]
        pub nullifier: u256,
        pub writer: ContractAddress
    }
    #[derive(Drop, starknet::Event)]
    pub struct WriterAdded {
        #[key]
        pub writer: ContractAddress
    }
    #[derive(Drop, starknet::Event)]
    pub struct WriterRemoved {
        #[key]
        pub writer: ContractAddress
    }


    // we need a constructor to initiate the is_writers array

    #[abi(embed_v0)]
    impl NullifierRegistryImpl of INullifierRegistry<ContractState> {
        fn add_nullifier(ref self: ContractState, nullifier: u256) {
            assert(self.is_nullified.read(nullifier), 'Nullifier already exists');

            self.is_nullified.write(nullifier, true);
            // emit event here
            self.emit(NullifierAdded { nullifier: nullifier, writer: get_caller_address(), });
        }

        fn add_write_permissions(ref self: ContractState, new_writer: ContractAddress) {
            assert(self.is_writers.read(new_writer), 'The Address is Already a writer');
            self.is_writers.write(new_writer, true);
            self.writers.write(self.writers_count.read() + 1, new_writer);
            // emit event
            self.emit(WriterAdded { writer: new_writer });
        }

        fn remove_writer_permissions(ref self: ContractState, remove_writer: ContractAddress) {
            assert!(self.is_writers.read(remove_writer), "Address is not a writer");
            self.is_writers.write(remove_writer, false);

            let mut i = 0;
            while i < self.writers_count.read() {
                if remove_writer == self.writers.read(i) {
                    self.writers.write(i, 0.try_into().unwrap());
                }
                i += 1;
            };

            self.emit(WriterRemoved { writer: remove_writer });
        }

        fn is_nullified(self: @ContractState, nullifier: u256) -> bool {
            return self.is_nullified.read(nullifier);
        }

        fn get_writers(self: @ContractState) -> Array<ContractAddress> {
            let mut writers = ArrayTrait::<ContractAddress>::new();

            let mut i = 0;
            while i < self.writers_count.read() {
                writers.append(self.writers.read(i));
                i += 1;
            };

            writers
        }
    }
}
