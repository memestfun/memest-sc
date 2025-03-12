module memest::memest;

use sui::balance::{Self, Balance};
use sui::coin::{Self, TreasuryCap, Coin};
use sui::sui::SUI;

const RATE: u64 = 1000;

public struct MEMEST has drop {}

public struct Storage has key {
    id: UID,
    balance: Balance<MEMEST>,
    blc: Balance<SUI>,
}

fun init(witness: MEMEST, ctx: &mut TxContext) {
    let (mut treasury, metadata) = coin::create_currency(
        witness,
        6,
        b"MEMEST",
        b"memest coin",
        b"memest coin",
        option::none(),
        ctx,
    );

    let coin = coin::mint(&mut treasury, std::u64::max_value!(), ctx);
    let storage = Storage {
        id: object::new(ctx),
        balance: coin.into_balance(),
        blc: balance::zero(),
    };

    transfer::share_object(storage);
    transfer::public_freeze_object(metadata);
    transfer::public_transfer(treasury, ctx.sender())
}

public fun buy(coin: Coin<SUI>, storage: &mut Storage, ctx: &mut TxContext): Coin<MEMEST> {
    let value = coin.value();
    let blc = coin.into_balance();
    storage.blc.join(blc);
    storage.balance.split(value * RATE).into_coin(ctx)
}

public fun mint(
    treasury_cap: &mut TreasuryCap<MEMEST>,
    storage: &mut Storage,
    amount: u64,
    ctx: &mut TxContext,
) {
    let balance = coin::mint(treasury_cap, amount, ctx).into_balance();
    storage.balance.join(balance);
}

#[test_only]
public fun test_init(ctx: &mut TxContext) {
    init(MEMEST {}, ctx)
}
