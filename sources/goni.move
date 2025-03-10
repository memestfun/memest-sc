module memest::goni;

use sui::coin::{Self, TreasuryCap};

public struct GONI has drop {}

fun init(witness: GONI, ctx: &mut TxContext) {
    let (treasury, metadata) = coin::create_currency(
        witness,
        6,
        b"GONI",
        b"",
        b"",
        option::none(),
        ctx,
    );
    transfer::public_freeze_object(metadata);
    transfer::public_transfer(treasury, ctx.sender())
}

public fun mint(
    treasury_cap: &mut TreasuryCap<GONI>,
    amount: u64,
    recipient: address,
    ctx: &mut TxContext,
) {
    let coin = coin::mint(treasury_cap, amount, ctx);
    transfer::public_transfer(coin, recipient)
}

#[test_only]
public fun test_init(ctx: &mut TxContext) {
    init(GONI {}, ctx)
}
