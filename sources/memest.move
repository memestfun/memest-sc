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

public struct NftBalance<phantom T> has key {
    id: UID,
    nft_id: ID,
    balance: Balance<T>,
}

#[allow(lint(self_transfer))]
public fun mint_a_nft(
    name: vector<u8>,
    description: vector<u8>,
    url: vector<u8>,
    ctx: &mut TxContext,
) {
    let sender = ctx.sender();

    let nft = Nft {
        id: object::new(ctx),
        name: string::utf8(name),
        description: string::utf8(description),
        url: url::new_unsafe_from_bytes(url),
    };

    transfer::public_transfer(nft, sender);
}

public fun transfer_nft(nft: Nft, recipient: address, _: &mut TxContext) {
    transfer::public_transfer(nft, recipient)
}

public fun wrap_coin<C: key + store>(nft: &mut Nft, coin: Coin<C>, ctx: &mut TxContext) {
    let sender = ctx.sender();

    let balance = coin::into_balance(coin);

    let nft_blc = NftBalance { id: object::new(ctx), balance, nft_id: object::id(nft) };

    transfer::transfer(nft_blc, sender);
}

#[allow(lint(self_transfer))]
public fun unwrap_coin<C: key + store>(nft: &Nft, nft_blc: NftBalance<C>, ctx: &mut TxContext) {
    let NftBalance {
        id,
        balance,
        nft_id,
    } = nft_blc;

    assert!(nft_id == object::id(nft), ENftAndNftBlcMissMatch);

    let sender = ctx.sender();
    let coin = coin::from_balance(balance, ctx);

    transfer::public_transfer(coin, sender);
    object::delete(id);
}
