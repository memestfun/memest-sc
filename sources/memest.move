module memest::memest;

use std::string::{Self, String};
use sui::balance::Balance;
use sui::coin::{Self, Coin};
use sui::url::{Self, Url};

const ENftAndNftBlcMissMatch: u64 = 0;

public struct Nft has key, store {
    id: UID,
    name: String,
    description: String,
    url: Url,
}

public struct NftBalance<phantom T> has key, store {
    id: UID,
    nft_id: ID,
    balance: Balance<T>,
}

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
    }
}

public fun burn_nft(nft: Nft, _: &mut TxContext) {
    let Nft { id, name: _, description: _, url: _ } = nft;
    id.delete();
}

public fun wrap_coin<C>(nft: &Nft, coin: Coin<C>, ctx: &mut TxContext): NftBalance<C> {
    let balance = coin::into_balance(coin);
    NftBalance { id: object::new(ctx), balance, nft_id: object::id(nft) }
}

public fun unwrap_coin<C>(nft: &Nft, nft_blc: NftBalance<C>, ctx: &mut TxContext): Coin<C> {
    let NftBalance {
        id,
        balance,
        nft_id,
    } = nft_blc;

    assert!(nft_id == object::id(nft), ENftAndNftBlcMissMatch);

    id.delete();
    coin::from_balance(balance, ctx)
}
