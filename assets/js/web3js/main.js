// `solanaWeb3` is provided in the global namespace by the `solanaWeb3.min.js` script bundle.

import {deriveLedgerPublicKey} from "./derive-ledger-public-key.js";
import {connection} from "./util.js";

let ledgerPublicKeyAndBump = await deriveLedgerPublicKey()

let accountBinary = await connection.getAccountInfo(ledgerPublicKeyAndBump.publicKey)

console.log(accountBinary)
