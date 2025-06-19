# Gift wrapper - NFT Wrapper Contract

This module allows users to **wrap fungible tokens into a single NFT**, transfer it, and later **unwrap** it to retrieve the original tokens.

---

## Features

- **Mint NFT**: Create a new NFT with custom metadata (name, description, URL).
- **Wrap Tokens**: Deposit fungible tokens (of any type) into the NFT.
- **Transfer NFT**: NFTs can be transferred like any object on-chain.
- **Unwrap Tokens**: Redeem the original tokens from the NFT.
- **Burn NFT**: Delete the NFT object when it's no longer needed.

---

## Module: `memest::vending_machine`

---

## Data Structures

### `Nft`
- Represents the wrapped NFT object.
- Fields:
  - `id: UID`
  - `name: String`
  - `description: String`
  - `url: Url`
  - `balances: Bag` (stores the wrapped tokens)

### `BalanceKey<phantom T>`
- Key type to manage balances of each token inside the Bag.

---

## Events

| Event             | Description |
|-------------------|-------------|
| `NftCreatedEvent`  | Emitted when an NFT is minted. |
| `WrapCoinEvent`    | Emitted when a token is wrapped into an NFT. |
| `UnwrapCoinEvent`  | Emitted when a token is unwrapped from an NFT. |
| `BurnNftEvent`     | Emitted when an NFT is burned. |

---

## Errors

| Code | Description |
|:-----|:------------|
| `0 (ENftNotContainCoin)` | Attempted to unwrap a token type that is not contained inside the NFT. |

---

## Public Functions

### `mint_a_nft`

```move
public fun mint_a_nft(name: vector<u8>, description: vector<u8>, url: vector<u8>, ctx: &mut TxContext): Nft
```
- Mints a new NFT with provided metadata.
- Emits `NftCreatedEvent`.

---

### `burn_nft`

```move
public fun burn_nft(nft: Nft, ctx: &mut TxContext)
```
- Burns (deletes) the NFT.
- **Only works if there are no tokens wrapped inside.**
- Emits `BurnNftEvent`.

---

### `wrap_coin`

```move
public fun wrap_coin<C>(nft: &mut Nft, coin: Coin<C>, ctx: &mut TxContext)
```
- Wraps a fungible token `Coin<C>` into the NFT.
- If the token type already exists, increases the balance.
- Emits `WrapCoinEvent`.

---

### `unwrap_coin`

```move
public fun unwrap_coin<C>(nft: &mut Nft, ctx: &mut TxContext): Coin<C>
```
- Unwraps a token of type `C` from the NFT.
- If the token is not found, it asserts and aborts with error code `ENftNotContainCoin`.
- Emits `UnwrapCoinEvent`.

---

### `nft_name`

```move
#[test_only]
public fun nft_name(nft: &Nft): String
```
- Returns the name of the NFT.
- Used internally for testing.

---

## Security Notes

- **Ownership**: Only the owner of the NFT can unwrap tokens.
- **Balance Handling**: Each token type is safely stored and retrieved using type-safe keys (`BalanceKey`).
- **Event Emission**: Every important operation is logged as an event.
- **Safe Burn**: NFTs must have no remaining balances before they can be burned.

---

## Potential Future Enhancements

- Allow wrapping multiple token types at once.
- Add time-lock or vesting conditions for unwrapping.
- Implement wrapping/unwrapping service fees.

---
