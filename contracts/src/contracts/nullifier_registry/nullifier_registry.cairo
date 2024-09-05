#[starknet::contract]
pub mod NullifierRegistry {
    use core::num::traits::zero::Zero;
    use core::option::OptionTrait;
    use openzeppelin::access::ownable::OwnableComponent;
    use starknet::{
        ContractAddress, get_caller_address, get_block_timestamp,
        storage::{Map, Vec, StorageMapReadAccess, StorageMapWriteAccess, VecTrait, MutableVecTrait}
    };
    use zkramp::contracts::nullifier_registry::interface::{
        INullifierRegistry, INullifierRegistryDispatcher, INullifierRegistryDispatcherTrait
    };

    component!(path: OwnableComponent, storage: ownable, event: OwnableEvent);

    #[abi(embed_v0)]
    impl OwnableImpl = OwnableComponent::OwnableImpl<ContractState>;

    impl OwnableInternalImpl = OwnableComponent::InternalImpl<ContractState>;


    #[storage]
    pub struct Storage {
        // / map(index -> writers address)
        writers: Map<u64, ContractAddress>,
        all_writers: Vec<ContractAddress>,
        writers_count: u64,
        is_nullified: Map<u256, bool>,
        is_writer: Map<ContractAddress, bool>,
        #[substorage(v0)]
        ownable: OwnableComponent::Storage,
    }


    #[event]
    #[derive(Drop, starknet::Event)]
    pub enum Event {
        #[flat]
        OwnableEvent: OwnableComponent::Event,
        NullifierAdded: NullifierAdded,
        WriterAdded: WriterAdded,
        WriterRemoved: WriterRemoved,
    }


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
    fn constructor(ref self: ContractState, owner: ContractAddress) {
        assert(!owner.is_zero(), 'Zero Address Pass');
        self.ownable.initializer(owner);
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


        fn add_write_permissions(ref self: ContractState, new_writer: ContractAddress) {
            self.ownable.assert_only_owner();
            assert(!self.is_writer(new_writer), 'The Address is Already a writer');
            self.is_writer.write(new_writer, true);
            self.writers.write(self.writers_count.read(), new_writer);
            self.all_writers.append().write(new_writer);
            self.writers_count.write(self.writers_count.read() + 1);
            // emit event
            self.emit(WriterAdded { writer: new_writer });
        }


        fn remove_writer_permissions(ref self: ContractState, remove_writer: ContractAddress) {
            self.ownable.assert_only_owner();
            assert(self.is_writer(remove_writer), 'Address is not a writer');
            self.is_writer.write(remove_writer, false);

            let mut i = 0;
            while i < self.writers_count.read() {
                if remove_writer == self.writers.read(i) {
                    self.writers.write(i, 0.try_into().unwrap());
                    self.all_writers.append().write(0.try_into().unwrap());
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
            self.is_writer.read(writer)
        }
    }
}

#[cfg(test)]
mod NullifierRegistry_tests {
    use core::traits::Into;
    use snforge_std::{
        declare, ContractClass, ContractClassTrait, spy_events, EventSpyAssertionsTrait,
        start_cheat_caller_address, stop_cheat_caller_address, EventSpy
    };
    use starknet::{ContractAddress};
    use super::NullifierRegistry;
    use zkramp::contracts::nullifier_registry::interface::{
        INullifierRegistry, INullifierRegistryDispatcher, INullifierRegistryDispatcherTrait
    };

    const OWNER_ADDR: felt252 = 0x1;


    fn deploy_NullifierRegistry(owner: felt252) -> ContractAddress {
        let mut nullifier_constructor_calldata = array![owner];
        let mut nullifier_contract = declare("NullifierRegistry").unwrap();
        let (contract_address, _) = nullifier_contract
            .deploy(@nullifier_constructor_calldata)
            .unwrap();

        contract_address
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
        let contract_address = deploy_NullifierRegistry(OWNER_ADDR);
        let nullifierDispatcher = INullifierRegistryDispatcher { contract_address };

        start_cheat_caller_address(contract_address, OWNER_ADDR.try_into().unwrap());
        nullifierDispatcher.add_write_permissions(WRITER_1());
        let writers = nullifierDispatcher.get_writers().span();
        assert(*writers.at(0) == WRITER_1(), 'wrong writer');
        stop_cheat_caller_address(contract_address);
        start_cheat_caller_address(contract_address, OWNER_ADDR.try_into().unwrap());
        nullifierDispatcher.add_write_permissions(WRITER_2());
        let writers = nullifierDispatcher.get_writers().span();
        assert(*writers.at(1) == WRITER_2(), 'wrong writer');
        stop_cheat_caller_address(contract_address);

        start_cheat_caller_address(contract_address, OWNER_ADDR.try_into().unwrap());
        nullifierDispatcher.add_write_permissions(WRITER_3());
        let writers = nullifierDispatcher.get_writers().span();
        assert(*writers.at(2) == WRITER_3(), 'wrong writer');
        stop_cheat_caller_address(contract_address);
    }

    #[test]
    fn test_remove_write_permissions() {
        let contract_address = deploy_NullifierRegistry(OWNER_ADDR);
        let nullifierDispatcher = INullifierRegistryDispatcher { contract_address };

        start_cheat_caller_address(contract_address, OWNER_ADDR.try_into().unwrap());
        nullifierDispatcher.add_write_permissions(WRITER_1());
        let writers = nullifierDispatcher.get_writers().span();
        assert(*writers.at(0) == WRITER_1(), 'wrong writer');
        stop_cheat_caller_address(contract_address);

        start_cheat_caller_address(contract_address, OWNER_ADDR.try_into().unwrap());
        nullifierDispatcher.add_write_permissions(WRITER_2());
        let writers = nullifierDispatcher.get_writers().span();
        assert(*writers.at(1) == WRITER_2(), 'wrong writer');
        stop_cheat_caller_address(contract_address);

        start_cheat_caller_address(contract_address, OWNER_ADDR.try_into().unwrap());
        nullifierDispatcher.remove_writer_permissions(WRITER_1());
        let is_writer = nullifierDispatcher.is_writer(WRITER_1());
        assert(!is_writer, 'not a writer');
        stop_cheat_caller_address(contract_address);

        start_cheat_caller_address(contract_address, OWNER_ADDR.try_into().unwrap());
        nullifierDispatcher.remove_writer_permissions(WRITER_2());
        let is_writer = nullifierDispatcher.is_writer(WRITER_2());
        assert(!is_writer, 'not a writer');

        stop_cheat_caller_address(contract_address);
    }

    #[test]
    #[should_panic(expected: ('The Address is Already a writer',))]
    fn test_add_write_permissions_already_added_writer() {
        let contract_address = deploy_NullifierRegistry(OWNER_ADDR);
        let nullifierDispatcher = INullifierRegistryDispatcher { contract_address };

        start_cheat_caller_address(contract_address, OWNER_ADDR.try_into().unwrap());
        nullifierDispatcher.add_write_permissions(WRITER_1());
        let writers = nullifierDispatcher.get_writers().span();
        assert(*writers.at(0) == WRITER_1(), 'wrong writer');
        stop_cheat_caller_address(contract_address);

        start_cheat_caller_address(contract_address, OWNER_ADDR.try_into().unwrap());
        nullifierDispatcher.add_write_permissions(WRITER_2());
        nullifierDispatcher.add_write_permissions(WRITER_2());
    }


    #[test]
    #[should_panic(expected: ('Address is not a writer',))]
    fn test_remove_write_permissions_already_remove_writer() {
        let contract_address = deploy_NullifierRegistry(OWNER_ADDR);
        let nullifierDispatcher = INullifierRegistryDispatcher { contract_address };

        start_cheat_caller_address(contract_address, OWNER_ADDR.try_into().unwrap());
        nullifierDispatcher.add_write_permissions(WRITER_1());
        let writers = nullifierDispatcher.get_writers().span();
        assert(*writers.at(0) == WRITER_1(), 'wrong writer');
        stop_cheat_caller_address(contract_address);

        start_cheat_caller_address(contract_address, OWNER_ADDR.try_into().unwrap());
        nullifierDispatcher.add_write_permissions(WRITER_2());
        let writers = nullifierDispatcher.get_writers().span();
        assert(*writers.at(1) == WRITER_2(), 'wrong writer');
        stop_cheat_caller_address(contract_address);

        start_cheat_caller_address(contract_address, OWNER_ADDR.try_into().unwrap());
        nullifierDispatcher.remove_writer_permissions(WRITER_1());
        nullifierDispatcher.remove_writer_permissions(WRITER_1());
    }


    #[test]
    fn test_add_nullifier() {
        let contract_address = deploy_NullifierRegistry(OWNER_ADDR);
        let nullifierDispatcher = INullifierRegistryDispatcher { contract_address };

        start_cheat_caller_address(contract_address, OWNER_ADDR.try_into().unwrap());
        nullifierDispatcher.add_write_permissions(WRITER_1());
        let writers = nullifierDispatcher.get_writers().span();
        assert(*writers.at(0) == WRITER_1(), 'wrong writer');
        stop_cheat_caller_address(contract_address);

        start_cheat_caller_address(contract_address, WRITER_1());

        nullifierDispatcher.add_nullifier(1_u256);
        assert(nullifierDispatcher.is_nullified(1_u256), 'should be nullified');
        stop_cheat_caller_address(contract_address);
    }

    #[test]
    #[should_panic(expected: ('Nullifier already exists',))]
    fn test_add_nullifier_with_existing_nullifier() {
        let contract_address = deploy_NullifierRegistry(OWNER_ADDR);
        let nullifierDispatcher = INullifierRegistryDispatcher { contract_address };

        start_cheat_caller_address(contract_address, OWNER_ADDR.try_into().unwrap());
        nullifierDispatcher.add_write_permissions(WRITER_1());
        let writers = nullifierDispatcher.get_writers().span();
        assert(*writers.at(0) == WRITER_1(), 'wrong writer');
        stop_cheat_caller_address(contract_address);

        start_cheat_caller_address(contract_address, WRITER_1());

        nullifierDispatcher.add_nullifier(1_u256);
        nullifierDispatcher.add_nullifier(1_u256);
    }

    #[test]
    fn test_get_writers() {
        let contract_address = deploy_NullifierRegistry(OWNER_ADDR);
        let nullifierDispatcher = INullifierRegistryDispatcher { contract_address };
        let length = 30_u32;

        start_cheat_caller_address(contract_address, OWNER_ADDR.try_into().unwrap());
        let mut x = 1;
        while x <= length {
            let addr: felt252 = x.into();
            nullifierDispatcher.add_write_permissions(addr.try_into().unwrap());
            x += 1;
        };
        let writers = nullifierDispatcher.get_writers();
        assert(writers.len() == length, 'wrong length');
        stop_cheat_caller_address(contract_address);
    }
}

