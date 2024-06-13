#[starknet::contract]
mod People {
    use openzeppelin::token::erc20::erc20::ERC20Component::InternalTrait;
use openzeppelin::token::erc20::{ERC20Component, ERC20HooksEmptyImpl};
    use starknet::ContractAddress;

    component!(path: ERC20Component, storage: erc20, event: ERC20Event);

    #[abi(embed_v0)]
    impl ERC20Impl = ERC20Component::ERC20MixinImpl<ContractState>;
    impl ERC20InternalImpl = ERC20Component::InternalImpl<ContractState>;

    #[storage]
    struct Storage {
        // First, specify the component macro.
        #[substorage(v0)]   // allows bringing a foreign storage into another storage.
        erc20: ERC20Component::Storage
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        ERC20Event: ERC20Component::Event
    }

    #[constructor]
    fn constructor(ref self: ContractState, recipient: ContractAddress, fixed_supply: u256) {
        self.erc20.initializer("ZKPeeps", "ZKP");
        self.erc20._mint(recipient, fixed_supply);
    }
}