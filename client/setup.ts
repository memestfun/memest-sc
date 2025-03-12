import { getFullnodeUrl, SuiClient } from "@mysten/sui/client"

export const goni_secret_key = ""

export const gonisbaby_secret_key = ""

export const package_id =
	"0x0fe25a24dd4a3bbafb8621cd03fee7b1a386189e74c297468c12bbd42c4af604"

export const storage_id =
	"0xdc4e490d75f1e5d97b611c4b5274842fa570a4feda1bed374a58941b0bc33f91"

export const client = new SuiClient({
	url: getFullnodeUrl("testnet")
})
