import { getFullnodeUrl, SuiClient } from "@mysten/sui/client"

export const goni_secret_key = ""

export const gonisbaby_secret_key = ""

export const package_id =
	"0x0c2a0046b94e660cf95ed3711814bb1495ae4f96bdd1f016da83ae6e98f3c390"

export const client = new SuiClient({
	url: getFullnodeUrl("localnet")
})
