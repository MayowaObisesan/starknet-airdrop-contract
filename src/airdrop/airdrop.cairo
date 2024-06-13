#[starknet::contract]
mod Airdrop {
    use starknet::{ContractAddress, get_block_timestamp, get_contract_address, get_caller_address};

    use people::interfaces::IERC20::{IERC20Dispatcher, IERC20DispatcherTrait};
    use people::interfaces::IAirdrop::IAirdrop;

    // IERC20DispatcherTrait
    // IERC20Dispatcher
    // IERC20LibraryDispatcher

    use people::ownable::ownable::Ownable;

    component!(path: Ownable, storage: ownable, event: OwnableEvent);

    #[storage]
    struct Storage {
        token_address: ContractAddress,
        registered_address: LegacyMap::<ContractAddress, bool>,
        claimed_address: LegacyMap::<ContractAddress, bool>,
        airdrop_start_time: u64,
        airdrop_end_time: u64,
        
        #[substorage(v0)]
        ownable: Ownable::Storage
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        OwnableEvent: Ownable::Event
    }

    #[abi(embed_v0)]
    impl OwnableImpl = Ownable::Ownable<ContractState>;

    const REGPRICE: u256 = 1000000000000000;
    const AIRDROP_AMOUNT: u256 = 1000;
    const ICO_DURATION: u64 = 86400_u64;
    const ETH_ADDRESS: felt252 = 0x049d36570d4e46f48e99674bd3fcc84644ddd6b96f7c741b1562b82f9e004dc7;

    #[constructor]
    fn constructor (
        ref self: ContractState,
        token_address: ContractAddress,
    ) {
        self.token_address.write(token_address);

        let current_time: u64 = get_block_timestamp();
        let end_time: u64 = current_time + ICO_DURATION;
        self.airdrop_start_time.write(current_time);
        self.airdrop_end_time.write(end_time);
    }

    #[abi(embed_v0)]
    impl AirdropImpl of IAirdrop<ContractState> {
        fn register(ref self: ContractState) {
            let current_time = get_block_timestamp();
            let caller = get_caller_address();
            let eth_address: ContractAddress = ETH_ADDRESS.try_into().unwrap();
            let this_contract = get_contract_address();

            // TODO: check ICO has not ended
            let airdrop_endtime = self.airdrop_end_time.read();
            assert(current_time < airdrop_endtime, 'airdrop has ended');
            
            // TODO: check user is not already registered
            let is_registered = self.registered_address.read(caller);
            assert(is_registered == false, 'You have already registered');
            // TODO: transfer REGPRICE from caller to this contract
            IERC20Dispatcher {contract_address: eth_address}.transfer_from(sender: caller, recipient: this_contract, amount: REGPRICE);
            
            //  TODO: set registered address to True
            self.registered_address.write(caller, true);
        }

        fn claim(ref self: ContractState, address: ContractAddress) {
            let current_time = get_block_timestamp();
            let airdrop_end_time = self.airdrop_end_time.read();
            let token_address = self.token_address.read();

            // TODO: check that user is registered
            assert(self.registered_address.read(address) == true, 'You are not registered');
            
            // TODO: check that ICO has ended
            assert(current_time > airdrop_end_time, 'Airdrop has ended');

            // TODO: check that user has not previously claimed
            let has_claimed = self.claimed_address.read(address);
            assert(!has_claimed, 'Sorry, you already claimed');
            
            // TODO: transfer PEOPLE token from contract to user
            IERC20Dispatcher {contract_address: token_address}.transfer(recipient: address, amount: AIRDROP_AMOUNT);

            // TODO: update claim address
            self.claimed_address.write(address, true);
        }

        fn is_registered(self: @ContractState, address: ContractAddress) -> bool {            
            // TODO: Check that the airdrop has not started
            // let current_time = get_block_timestamp();
            // let airdrop_starttime = self.airdrop_start_time.read();
            // assert(current_time > airdrop_starttime, 'airdrop has already started');
            
            // TOOD: check user's registration status
            self.registered_address.read(address)
        }
    }
}