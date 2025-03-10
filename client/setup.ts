import { getFullnodeUrl, SuiClient } from "@mysten/sui/client"

export const goni_secret_key = ""

export const gonisbaby_secret_key = ""

export const package_id =
	"0x48d9608a878a14dd9e389c6badfab6d7967a6c8febb0cbbf0f39b1061467f0d5"

export const treasury_cap =
	"0x423b2f121b0d26a18e2a4f2843444308852fbb8089e49547bb0620d05b99ffcc"

export const client = new SuiClient({
	url: getFullnodeUrl("localnet")
})
