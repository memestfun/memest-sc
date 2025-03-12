import { getFullnodeUrl, SuiClient } from "@mysten/sui/client"

export const goni_secret_key = ""

export const gonisbaby_secret_key = ""

export const package_id =
	"0xbb9f6605acdd3f9e0175db00df3ea385ab94df20205822ef6da6c1cabe7455c1"

export const client = new SuiClient({
	url: getFullnodeUrl("localnet")
})
