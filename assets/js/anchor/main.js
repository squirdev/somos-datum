import {programID} from "./config";
import {publicKey} from "./state";
import {connection, getProvider} from "./util";

console.log(programID)

let ledgerPublicKey = await publicKey()

let accountBinary = await connection.getAccountInfo(ledgerPublicKey.publicKey)

console.log("account-binary:")
console.log(accountBinary)

const provider = await getProvider()
console.log(provider)
