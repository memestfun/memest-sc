import { getFullnodeUrl, SuiClient } from "@mysten/sui/client"

export const goni_secret_key = ""

export const gonisbaby_secret_key = ""

export const package_id =
	"0xf1c84f3b63a233ad9706ced7fda88c1dadc5748bbb7f8cfc21dfe87274a314a3"

export const client = new SuiClient({
	url: getFullnodeUrl("testnet")
})
