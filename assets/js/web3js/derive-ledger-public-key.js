// `solanaWeb3` is provided in the global namespace by the `solanaWeb3.min.js` script bundle.
import {ACCOUNT_SEED, programID} from "./config.js";
import {textEncoder} from "./util.js";

export async function deriveLedgerPublicKey() {
    let publicKey_, bump_ = null;
    [publicKey_, bump_] = await solanaWeb3.PublicKey.findProgramAddress(
        [textEncoder.encode(ACCOUNT_SEED)],
        programID
    );
    return {publicKey: publicKey_, bump: bump_}
}
