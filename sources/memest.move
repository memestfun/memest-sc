module memest::memest;

use std::string::{Self, String};
use sui::bag::{Self, Bag};
use sui::balance::Balance;
use sui::coin::{Self, Coin};
use sui::url::{Self, Url};

/// NFT identifier.
public struct Nft has key, store {
    id: UID,
    name: String,
    description: String,
    url: Url,
    balances: Bag,
}

/// Balance identifier.
public struct BalanceKey<phantom T> has copy, drop, store {}

const ENftNotContainCoin: u64 = 0;

public fun mint_a_nft(
    name: vector<u8>,
    description: vector<u8>,
    url: vector<u8>,
    ctx: &mut TxContext,
): Nft {
    Nft {
        id: object::new(ctx),
        name: string::utf8(name),
        description: string::utf8(description),
        url: url::new_unsafe_from_bytes(url),
        balances: bag::new(ctx),
    }
}

public fun burn_nft(nft: Nft, _: &mut TxContext) {
    let Nft { id, name: _, description: _, url: _, balances } = nft;
    balances.destroy_empty();
    id.delete();
}

public fun wrap_coin<C>(nft: &mut Nft, coin: Coin<C>, _ctx: &mut TxContext) {
    let asset_blc = coin::into_balance(coin);

    let key = BalanceKey<C> {};

    if (nft.balances.contains(key)) {
        let balance: &mut Balance<C> = &mut nft.balances[key];
        balance.join(asset_blc);
    } else {
        nft.balances.add(key, asset_blc);
    }
}

public fun unwrap_coin<C>(nft: &mut Nft, ctx: &mut TxContext): Coin<C> {
    let key = BalanceKey<C> {};

    let key_exists = nft.balances.contains(key);

    assert!(key_exists, ENftNotContainCoin);

    let balance = nft.balances.remove(key);

    coin::from_balance(balance, ctx)
}

#[test_only]
public fun name(nft: &Nft): String {
    nft.name
}
