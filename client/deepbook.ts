// Copyright (c) Mysten Labs, Inc.
// SPDX-License-Identifier: Apache-2.0
import { type BalanceManager, DeepBookClient } from "@mysten/deepbook-v3"
import { getFullnodeUrl, SuiClient } from "@mysten/sui/client"
import { decodeSuiPrivateKey } from "@mysten/sui/cryptography"
import type { Keypair } from "@mysten/sui/cryptography"
import { Ed25519Keypair } from "@mysten/sui/keypairs/ed25519"
import { Transaction } from "@mysten/sui/transactions"

const BALANCE_MANAGER_KEY = "MANAGER_1"

export class DeepBookMarketMaker extends DeepBookClient {
	keypair: Keypair
	suiClient: SuiClient

	constructor(
		keypair: string | Keypair,
		env: "testnet" | "mainnet",
		balanceManagers?: { [key: string]: BalanceManager },
		adminCap?: string
	) {
		let resolvedKeypair: Keypair

		if (typeof keypair === "string") {
			resolvedKeypair = DeepBookMarketMaker.getSignerFromPK(keypair)
		} else {
			resolvedKeypair = keypair
		}

		const address = resolvedKeypair.toSuiAddress()

		super({
			address: address,
			env: env,
			client: new SuiClient({
				url: getFullnodeUrl(env)
			}),
			balanceManagers: balanceManagers,
			adminCap: adminCap
		})

		this.keypair = resolvedKeypair
		this.suiClient = new SuiClient({
			url: getFullnodeUrl(env)
		})
	}

	static getSignerFromPK(privateKey: string) {
		const { schema, secretKey } = decodeSuiPrivateKey(privateKey)
		if (schema === "ED25519") return Ed25519Keypair.fromSecretKey(secretKey)

		throw new Error(`Unsupported schema: ${schema}`)
	}

	async signAndExecute(tx: Transaction) {
		return this.suiClient.signAndExecuteTransaction({
			transaction: tx,
			signer: this.keypair
		})
	}

	getActiveAddress() {
		return this.keypair.getPublicKey().toSuiAddress()
	}

	async createBalanceManagerAndReinitialize() {
		const tx = new Transaction()
		tx.add(this.balanceManager.createAndShareBalanceManager())

		const res = await this.suiClient.signAndExecuteTransaction({
			transaction: tx,
			signer: this.keypair,
			options: {
				showEffects: true,
				showObjectChanges: true
			}
		})

		// @ts-ignore
		const balanceManagerAddress = res.objectChanges?.find(change => {
			return (
				change.type === "created" &&
				change.objectType.includes("BalanceManager")
			)
			// biome-ignore lint/complexity/useLiteralKeys: <explanation>
		})?.["objectId"]

		const balanceManagers: { [key: string]: BalanceManager } = {
			[BALANCE_MANAGER_KEY]: {
				address: balanceManagerAddress,
				tradeCap: undefined
			}
		}

		return balanceManagers
	}

	// Example of a flash loan transaction
	// Borrow 1 DEEP from DEEP_SUI pool
	// Swap 0.3 SUI for DBUSDC in SUI_DBUSDC pool, pay with deep borrowed
	// Swap SUI back to DEEP
	// Return 1 DEEP to DEEP_SUI pool
	flashLoanExample(tx: Transaction) {
		// const borrowAmount = 1

		// const [deepCoin, flashLoan] = tx.add(
		// 	this.flashLoans.borrowBaseAsset("DEEP_SUI", borrowAmount)
		// )

		// Execute second trade to get back DEEP for repayment
		// const [baseOut2, quoteOut2, deepOut2] = tx.add(
		// 	this.deepBook.swapExactQuoteForBase({
		// 		poolKey: "DEEP_SUI",
		// 		amount: 1,
		// 		minOut: 0,
		// 		deepAmount: 0
		// 	})
		// )

		// tx.transferObjects([quoteOut2, deepOut2], this.getActiveAddress())

		// Execute trade using borrowed DEEP
		const [baseOut, quoteOut, deepOut] = tx.add(
			this.deepBook.swapExactBaseForQuote({
				poolKey: "SUI_DBUSDC",
				amount: 1,
				deepAmount: 0,
				minOut: 0
				// deepCoin: baseOut2
			})
		)

		tx.transferObjects([baseOut, quoteOut, deepOut], this.getActiveAddress())

		// Return borrowed DEEP
		// const loanRemain = tx.add(
		// 	this.flashLoans.returnBaseAsset(
		// 		"DEEP_SUI",
		// 		borrowAmount,
		// 		baseOut2,
		// 		flashLoan
		// 	)
		// )

		// // Send the remaining coin to user's address
		// tx.transferObjects([loanRemain], this.getActiveAddress())
	}
}

async function main() {
	const signer = DeepBookMarketMaker.getSignerFromPK(
		"suiprivkey1qqcs46kmy3j5hnjnd534qfasa4hy3kfhk2vgmcttc940q4fnzr4q24v93vs"
	)

	const client = new DeepBookMarketMaker(signer, "testnet")

	// const tx = new Transaction()
	// client.flashLoanExample(tx)

	// const result = await client.suiClient.signAndExecuteTransaction({
	// 	transaction: tx,
	// 	signer
	// })

	// await client.suiClient.waitForTransaction({
	// 	digest: result.digest,
	// 	options: { showEffects: true }
	// })

	// console.log("result: ", result)
	// console.log("digest: ", result.digest)

	// console.log(
	// 	await client.suiClient.getAllBalances({ owner: signer.toSuiAddress() })
	// )

	console.log(
		await client.getPoolIdByAssets(
			"0xf7152c05930480cd740d7311b5b8b45c6f488e3a53a11c3f74a6fac36a52e0d7::DBUSDT::DBUSDT",
			"0x0000000000000000000000000000000000000000000000000000000000000002::sui::SUI"
		)
	)
}

main()
