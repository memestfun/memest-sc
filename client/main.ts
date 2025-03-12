import { Ed25519Keypair } from "@mysten/sui/keypairs/ed25519"
import { Transaction } from "@mysten/sui/transactions"
import { fromHex } from "@mysten/sui/utils"

import {
	client,
	package_id,
	goni_secret_key,
	gonisbaby_secret_key,
	storage_id
} from "./setup"

const goni = Ed25519Keypair.fromSecretKey(fromHex(goni_secret_key))
const gonisbaby = Ed25519Keypair.fromSecretKey(fromHex(gonisbaby_secret_key))

async function main() {
	const coin = await buy_memest()
	console.log("done buy 10 MEMEST")

	const nft = await mint_nft_and_wrap_coin(coin)
	console.log("done mint a nft, wrap token then transfer nft to gonisbaby")

	await unwrap_nft(nft)
	console.log("done unwrap nft and burn nft")
}

main()

async function buy_memest(): Promise<string> {
	const tx = new Transaction()

	const [coin] = tx.splitCoins(tx.gas, [10_000_000]) // 0.001 SUI

	const memest_coin = tx.moveCall({
		target: `${package_id}::memest::buy`,
		arguments: [tx.object(coin), tx.object(storage_id)]
	})

	tx.transferObjects([memest_coin], goni.toSuiAddress())

	const result = await client.signAndExecuteTransaction({
		signer: goni,
		transaction: tx
	})

	await client.waitForTransaction({ digest: result.digest })

	const {
		data: [memest]
	} = await client.getOwnedObjects({
		owner: goni.toSuiAddress(),
		filter: {
			StructType: `0x2::coin::Coin<${package_id}::memest::MEMEST>`
		}
	})

	return memest.data?.objectId!
}

async function mint_nft_and_wrap_coin(coin: string): Promise<string> {
	const tx = new Transaction()

	const nft = tx.moveCall({
		target: `${package_id}::vending_machine::mint_a_nft`,
		arguments: [
			tx.pure.vector("u8", []),
			tx.pure.vector("u8", []),
			tx.pure.vector("u8", [])
		]
	})

	tx.moveCall({
		target: `${package_id}::vending_machine::wrap_coin`,
		typeArguments: [`${package_id}::memest::MEMEST`],
		arguments: [nft, tx.object(coin)]
	})

	tx.transferObjects([nft], gonisbaby.toSuiAddress())

	const result = await client.signAndExecuteTransaction({
		signer: goni,
		transaction: tx
	})

	await client.waitForTransaction({ digest: result.digest })

	const {
		data: [nft_obj]
	} = await client.getOwnedObjects({
		owner: gonisbaby.toSuiAddress(),
		filter: {
			StructType: `${package_id}::vending_machine::Nft`
		}
	})

	return nft_obj.data?.objectId!
}

async function unwrap_nft(nft: string) {
	const txn = new Transaction()

	const coin = txn.moveCall({
		target: `${package_id}::vending_machine::unwrap_coin`,
		typeArguments: [`${package_id}::memest::MEMEST`],
		arguments: [txn.object(nft)]
	})

	txn.moveCall({
		target: `${package_id}::vending_machine::burn_nft`,
		arguments: [txn.object(nft)]
	})

	txn.transferObjects([coin], gonisbaby.toSuiAddress())

	const rs = await client.signAndExecuteTransaction({
		signer: gonisbaby,
		transaction: txn
	})

	await client.waitForTransaction({ digest: rs.digest })
}
