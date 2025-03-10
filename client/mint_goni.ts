import { Ed25519Keypair } from "@mysten/sui/keypairs/ed25519";
import { Transaction } from "@mysten/sui/transactions";
import { fromHex } from "@mysten/sui/utils";
import { client, package_id, goni_secret_key, treasury_cap } from "./setup";

async function mint() {
	const goni = Ed25519Keypair.fromSecretKey(fromHex(goni_secret_key));

	const tx = new Transaction();

	tx.moveCall({
		target: `${package_id}::goni::mint`,
		arguments: [
			tx.object(treasury_cap),
			tx.pure.u64(16_000_000),
			tx.pure.address(goni.toSuiAddress()),
		],
	});

	const result = await client.signAndExecuteTransaction({
		signer: goni,
		transaction: tx,
	});

	await client.waitForTransaction({ digest: result.digest });
}

mint();
