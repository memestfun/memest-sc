#[test_only]
module memest::memest_tests;

use sui::coin::Coin;

const GONI: address = @0xa;
const ALICE: address = @0xb;
const BLAIR: address = @0xc;

#[test]
fun scripts() {
    use sui::test_scenario;

    let mut scenario = test_scenario::begin(GONI);
    {
        memest::memest::test_init(scenario.ctx());
    };

    scenario.next_tx(ALICE);
    {
        let coin = scenario.take_from_sender<Coin<memest::memest::MEMEST>>();
        assert!(coin.value() == 1_000_000);
        scenario.return_to_sender(coin);
    };

    scenario.next_tx(ALICE);
    {
        let coin = scenario.take_from_sender<Coin<memest::memest::MEMEST>>();
        let mut nft = memest::vending_machine::mint_a_nft(
            vector::empty(),
            vector::empty(),
            vector::empty(),
            scenario.ctx(),
        );
        memest::vending_machine::wrap_coin(&mut nft, coin, scenario.ctx());
        transfer::public_transfer(nft, BLAIR);
    };

    scenario.next_tx(BLAIR);
    {
        let mut nft = scenario.take_from_sender<memest::vending_machine::Nft>();
        assert!(memest::vending_machine::nft_name(&nft).length() > 0);

        let coin =
            memest::vending_machine::unwrap_coin<memest::memest::MEMEST>(&mut nft, scenario.ctx());
        assert!(coin.value() == 1_000_000);

        memest::vending_machine::burn_nft(nft, scenario.ctx());
        transfer::public_transfer(coin, BLAIR);
    };

    scenario.end();
}
