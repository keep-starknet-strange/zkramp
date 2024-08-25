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
        // / map(index -> writers address)
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


    #[constructor]
    fn constructor(ref self: ContractState) {
        self.writers_count.write(0);
    }

    #[abi(embed_v0)]
    impl NullifierRegistryImpl of INullifierRegistry<ContractState> {
        fn add_nullifier(ref self: ContractState, nullifier: u256) {
            assert(self.is_writer(get_caller_address()), 'Caller is not a writer');
            assert(!self.is_nullified(nullifier), 'Nullifier already exists');

            self.is_nullified.write(nullifier, true);
            // emit event here
            self.emit(NullifierAdded { nullifier: nullifier, writer: get_caller_address(), });
        }

        //TODO: restrict to only Owner
        fn add_write_permissions(ref self: ContractState, new_writer: ContractAddress) {
            assert(!self.is_writer(new_writer), 'The Address is Already a writer');
            self.is_writers.write(new_writer, true);
            self.writers.write(self.writers_count.read(), new_writer);
            self.writers_count.write(self.writers_count.read() + 1);
            // emit event
            self.emit(WriterAdded { writer: new_writer });
        }

        //TODO: restrict to only Owner
        fn remove_writer_permissions(ref self: ContractState, remove_writer: ContractAddress) {
            assert(self.is_writer(remove_writer), 'Address is not a writer');
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

        fn is_writer(self: @ContractState, writer: ContractAddress) -> bool {
            self.is_writers.read(writer)
        }
    }
}

#[cfg(test)]
mod NullifierRegistry_tests {
    use core::traits::Into;
    use snforge_std::{
        declare, ContractClass, ContractClassTrait, spy_events, EventSpyAssertionsTrait,
        start_cheat_caller_address, EventSpy
    };
    use starknet::{ContractAddress};
    use super::NullifierRegistry;
    use zkramp::contracts::nullifier_registry::interface::{
        INullifierRegistry, INullifierRegistryDispatcher, INullifierRegistryDispatcherTrait
    };

    fn deploy_NullifierRegistry() -> (ContractAddress, INullifierRegistryDispatcher, EventSpy) {
        let mut class = declare("NullifierRegistry").unwrap();
        let (contract_address, _) = class.deploy(@array![]).unwrap();

        (contract_address, INullifierRegistryDispatcher { contract_address }, spy_events())
    }

    fn WRITER_1() -> ContractAddress {
        1.try_into().unwrap()
    }

    fn WRITER_2() -> ContractAddress {
        2.try_into().unwrap()
    }

    fn WRITER_3() -> ContractAddress {
        3.try_into().unwrap()
    }


    #[test]
    fn test_add_write_permissions() {
        let (contract_address, dispatcher, mut spy) = deploy_NullifierRegistry();

        dispatcher.add_write_permissions(WRITER_1());
        dispatcher.add_write_permissions(WRITER_2());
        dispatcher.add_write_permissions(WRITER_3());

        let writers = dispatcher.get_writers().span();

        assert(*writers.at(0) == WRITER_1(), 'wrong writer');
        assert(*writers.at(1) == WRITER_2(), 'wrong writer');
        assert(*writers.at(2) == WRITER_3(), 'wrong writer');

        spy
            .assert_emitted(
                @array![
                    (
                        contract_address,
                        NullifierRegistry::Event::WriterAdded(
                            NullifierRegistry::WriterAdded { writer: WRITER_1() }
                        )
                    ),
                    (
                        contract_address,
                        NullifierRegistry::Event::WriterAdded(
                            NullifierRegistry::WriterAdded { writer: WRITER_2() }
                        )
                    ),
                    (
                        contract_address,
                        NullifierRegistry::Event::WriterAdded(
                            NullifierRegistry::WriterAdded { writer: WRITER_3() }
                        )
                    )
                ]
            );
    }

    #[test]
    #[should_panic(expected: ('The Address is Already a writer',))]
    fn test_add_write_permissions_with_existing_writer() {
        let (_, dispatcher, _) = deploy_NullifierRegistry();
        dispatcher.add_write_permissions(WRITER_1().into());
        dispatcher.add_write_permissions(WRITER_1().into());
    }

    #[test]
    fn test_add_nullifier() {
        let (contract_address, dispatcher, mut spy) = deploy_NullifierRegistry();

        dispatcher.add_write_permissions(WRITER_1());
        start_cheat_caller_address(contract_address, WRITER_1());

        dispatcher.add_nullifier(1_u256);
        assert(dispatcher.is_nullified(1_u256), 'should be nullified');

        spy
            .assert_emitted(
                @array![
                    (
                        contract_address,
                        NullifierRegistry::Event::NullifierAdded(
                            NullifierRegistry::NullifierAdded {
                                nullifier: 1_u256, writer: WRITER_1()
                            }
                        )
                    )
                ]
            );
    }

    #[test]
    #[should_panic(expected: ('Caller is not a writer',))]
    fn test_add_nullifier_with_non_writer() {
        let (_, dispatcher, _) = deploy_NullifierRegistry();

        dispatcher.add_nullifier(1_u256);
        dispatcher.add_nullifier(1_u256);
    }

    #[test]
    #[should_panic(expected: ('Nullifier already exists',))]
    fn test_add_nullifier_with_existing_nullifier() {
        let (contract_address, dispatcher, _) = deploy_NullifierRegistry();

        dispatcher.add_write_permissions(WRITER_1());
        start_cheat_caller_address(contract_address, WRITER_1());

        dispatcher.add_nullifier(1_u256);
        dispatcher.add_nullifier(1_u256);
    }

    #[test]
    fn test_remove_writer_permissions() {
        let (contract_address, dispatcher, mut spy) = deploy_NullifierRegistry();

        dispatcher.add_write_permissions(WRITER_1());
        assert(dispatcher.is_writer(WRITER_1()), 'should be a writer');

        dispatcher.remove_writer_permissions(WRITER_1());
        assert(!dispatcher.is_writer(WRITER_1()), 'not a writer');

        spy
            .assert_emitted(
                @array![
                    (
                        contract_address,
                        NullifierRegistry::Event::WriterRemoved(
                            NullifierRegistry::WriterRemoved { writer: WRITER_1() }
                        )
                    )
                ]
            );
    }

    #[test]
    #[should_panic(expected: ('Address is not a writer',))]
    fn test_remove_writer_permissions_non_writter() {
        let (_, dispatcher, _) = deploy_NullifierRegistry();

        dispatcher.remove_writer_permissions(WRITER_1());
    }

    #[test]
    fn test_get_writers() {
        let (_, dispatcher, _) = deploy_NullifierRegistry();
        let length = 30_u32;

        let mut x = 1;
        while x <= length {
            let addr: felt252 = x.into();
            dispatcher.add_write_permissions(addr.try_into().unwrap());
            x += 1;
        };

        let writers = dispatcher.get_writers();
        assert(writers.len() == length, 'wrong length');

        let mut i = 1;
        while i <= length {
            let addr: felt252 = i.into();
            assert(*writers.at(i - 1) == addr.try_into().unwrap(), 'wrong address');
            i += 1;
        }
    }
}

