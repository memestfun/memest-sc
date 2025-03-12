module memest::vending_machine;

use std::string::{Self, String};
use std::type_name::{Self, TypeName};
use sui::bag::{Self, Bag};
use sui::balance::Balance;
use sui::coin::{Self, Coin};
use sui::event;
use sui::url::{Self, Url};

// === Errors ===
const ENftNotContainCoin: u64 = 0;

// === Structs ===
public struct Nft has key, store {
    id: UID,
    name: String,
    description: String,
    url: Url,
    balances: Bag,
}

public struct BalanceKey<phantom T> has copy, drop, store {}

// === Events ===
public struct NftCreatedEvent has copy, drop {
    id: ID,
    name: String,
    description: String,
    url: Url,
}

public struct WrapCoinEvent has copy, drop {
    nft_id: ID,
    coin: String,
    blc: u64,
}

public struct UnwrapCoinEvent has copy, drop {
    nft_id: ID,
    coin: String,
    blc: u64,
}

public struct BurnNftEvent has copy, drop {
    nft_id: ID,
}

public fun mint_a_nft(
    name: vector<u8>,
    description: vector<u8>,
    url: vector<u8>,
    ctx: &mut TxContext,
): Nft {
    let nft = Nft {
        id: object::new(ctx),
        name: string::utf8(name),
        description: string::utf8(description),
        url: url::new_unsafe_from_bytes(url),
        balances: bag::new(ctx),
    };

    event::emit(NftCreatedEvent {
        id: object::id(&nft),
        name: nft.name,
        description: nft.description,
        url: nft.url,
    });

    nft
}

public fun burn_nft(nft: Nft, _: &mut TxContext) {
    let Nft { id, name: _, description: _, url: _, balances } = nft;
    event::emit(BurnNftEvent { nft_id: id.to_inner() });
    balances.destroy_empty();
    id.delete();
}

public fun wrap_coin<C>(nft: &mut Nft, coin: Coin<C>, _ctx: &mut TxContext) {
    let asset_blc = coin::into_balance(coin);
    let amount = asset_blc.value();

    let key = BalanceKey<C> {};

    if (nft.balances.contains(key)) {
        let balance: &mut Balance<C> = &mut nft.balances[key];
        balance.join(asset_blc);
    } else {
        nft.balances.add(key, asset_blc);
    };

    let coin_type: TypeName = type_name::get<C>();

    event::emit(WrapCoinEvent {
        nft_id: object::id(nft),
        coin: coin_type.get_address().to_string(),
        blc: amount,
    });
}

public fun unwrap_coin<C>(nft: &mut Nft, ctx: &mut TxContext): Coin<C> {
    let key = BalanceKey<C> {};

    let key_exists = nft.balances.contains(key);

    assert!(key_exists, ENftNotContainCoin);

    let balance: Balance<C> = nft.balances.remove(key);

    let coin_type: TypeName = type_name::get<C>();

    event::emit(UnwrapCoinEvent {
        nft_id: object::id(nft),
        coin: coin_type.get_address().to_string(),
        blc: balance.value(),
    });

    coin::from_balance(balance, ctx)
}

#[test_only]
public fun nft_name(nft: &Nft): String {
    nft.name
}
