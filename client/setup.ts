import { getFullnodeUrl, SuiClient } from "@mysten/sui/client"

export const goni_secret_key = ""

export const gonisbaby_secret_key = ""

export const package_id =
	"0x0135bc4cc6ce79fbd29fc5c363b9dd2ab1a42216088e3110ddbe719c98b1ad11"

export const client = new SuiClient({
	url: getFullnodeUrl("localnet")
})
