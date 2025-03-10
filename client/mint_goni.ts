import { getFullnodeUrl, SuiClient } from "@mysten/sui/client";
import { Ed25519Keypair } from "@mysten/sui/keypairs/ed25519";
import { Transaction } from "@mysten/sui/transactions";
import { fromHex } from "@mysten/sui/utils";
import { package_id, secret_key, treasury_cap } from "./objs";

async function mint() {
	const client = new SuiClient({
		url: getFullnodeUrl("localnet"),
	});

	const signer = Ed25519Keypair.fromSecretKey(fromHex(secret_key));

	const tx = new Transaction();

	tx.moveCall({
		target: `${package_id}::goni::mint`,
		arguments: [
			tx.object(treasury_cap),
			tx.pure.u64(16_000_000),
			tx.pure.address(signer.toSuiAddress()),
		],
	});

	const result = await client.signAndExecuteTransaction({
		signer,
		transaction: tx,
	});

	await client.waitForTransaction({ digest: result.digest });
}

mint();
