#[test_only]
module memest::memest_tests;

use sui::coin::{TreasuryCap, Coin};

const GONI: address = @0xa;
const ALICE: address = @0xb;
const BLAIR: address = @0xc;

#[test]
fun scripts() {
    use sui::test_scenario;

    let mut scenario = test_scenario::begin(GONI);
    {
        memest::goni::test_init(scenario.ctx());
    };

    scenario.next_tx(GONI);
    {
        let mut treasury_cap = scenario.take_from_sender<TreasuryCap<memest::goni::GONI>>();
        memest::goni::mint(&mut treasury_cap, 1_000_000, ALICE, scenario.ctx());
        scenario.return_to_sender(treasury_cap);
    };

    scenario.next_tx(ALICE);
    {
        let coin = scenario.take_from_sender<Coin<memest::goni::GONI>>();
        assert!(coin.value() == 1_000_000);
        scenario.return_to_sender(coin);
    };

    scenario.next_tx(ALICE);
    {
        let coin = scenario.take_from_sender<Coin<memest::goni::GONI>>();
        let mut nft = memest::memest::mint_a_nft(
            vector::empty(),
            vector::empty(),
            vector::empty(),
            scenario.ctx(),
        );
        memest::memest::wrap_coin(&mut nft, coin, scenario.ctx());
        transfer::public_transfer(nft, BLAIR);
    };

    scenario.next_tx(BLAIR);
    {
        let mut nft = scenario.take_from_sender<memest::memest::Nft>();
        assert!(memest::memest::name(&nft).is_empty());

        let coin = memest::memest::unwrap_coin<memest::goni::GONI>(&mut nft, scenario.ctx());
        assert!(coin.value() == 1_000_000);

        memest::memest::burn_nft(nft, scenario.ctx());
        transfer::public_transfer(coin, BLAIR);
    };

    scenario.end();
}
