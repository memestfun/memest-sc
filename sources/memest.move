module memest::memest;

use std::string::{Self, String};
use sui::balance::Balance;
use sui::coin::{Self, Coin};
use sui::transfer::Receiving;
use sui::url::{Self, Url};

public struct Nft has key, store {
    id: UID,
    name: String,
    description: String,
    url: Url,
}

public struct NftBalance<phantom T> has key, store {
    id: UID,
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

public fun wrap_coin<C>(nft: &Nft, coin: Coin<C>, ctx: &mut TxContext) {
    let balance = coin::into_balance(coin);
    let nft_blc = NftBalance { id: object::new(ctx), balance };

    transfer::transfer(nft_blc, object::id_address(nft));
}

public fun unwrap_coin<C>(
    nft: &mut Nft,
    wrapped_nft_blc: Receiving<NftBalance<C>>,
    ctx: &mut TxContext,
): Coin<C> {
    let nft_blc = transfer::public_receive(&mut nft.id, wrapped_nft_blc);
    let NftBalance {
        id,
        balance,
    } = nft_blc;

    object::delete(id);
    coin::from_balance(balance, ctx)
}

public fun name(nft: &Nft): String {
    nft.name
}

public fun description(nft: &Nft): String {
    nft.description
}

public fun url(nft: &Nft): Url {
    nft.url
}

#[test_only]
public fun nft_blc<C>(nft_blc: &NftBalance<C>): u64 {
    nft_blc.balance.value()
}
