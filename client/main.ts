import { SuiClient, getFullnodeUrl } from "@mysten/sui/client";
import { Ed25519Keypair } from "@mysten/sui/keypairs/ed25519";
import { Transaction } from "@mysten/sui/transactions";
import { fromHex } from "@mysten/sui/utils";

import { package_id, secret_key } from "./objs";

async function main() {
	const client = new SuiClient({
		url: getFullnodeUrl("localnet"),
	});

	const signer = Ed25519Keypair.fromSecretKey(fromHex(secret_key));

	const tx = new Transaction();

	const nft = tx.moveCall({
		target: `${package_id}::memest::mint_a_nft`,
		arguments: [
			tx.pure.vector("u8", []),
			tx.pure.vector("u8", []),
			tx.pure.vector("u8", []),
		],
	});

	const nft_blc = tx.moveCall({
		target: `${package_id}::memest::wrap_coin`,
		typeArguments: [`${package_id}::goni::GONI`],
		arguments: [
			nft,
			tx.object(
				"0x09def222a9c3dbd3f15d384be7d4289329b7f446e9e32b9e8a0f9f9f93b9e78d",
			),
		],
	});

	tx.transferObjects(
		[nft_blc, nft],
		"0x08d80f1cdf83b45cc33ee7ecc4729e5ca59a8d429c302a2c82b6af9fa37f9908",
	);

	const result = await client.signAndExecuteTransaction({
		signer,
		transaction: tx,
	});

	await client.waitForTransaction({ digest: result.digest });

	console.log("result: ", result);
}

main();
