import {deriveLedgerPublicKey} from "./derive-ledger-public-key.js";
import {connection} from "./util.js";
import {solanaWeb3} from "./index.js";

let ledgerPublicKeyAndBump = await deriveLedgerPublicKey()

let accountBinary = await connection.getAccountInfo(ledgerPublicKeyAndBump.publicKey)

console.log(accountBinary)
console.log(solanaWeb3)
console.log(solanaWeb3.BN)
console.log(new solanaWeb3.BN(1234))
//console.log(deserialize)
