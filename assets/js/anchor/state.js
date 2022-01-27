import {web3} from "@project-serum/anchor";
import {ACCOUNT_SEED, programID} from "./config.js";
import {textEncoder} from "./util.js";

async function _publicKey() {
    let publicKey_, bump_ = null;
    [publicKey_, bump_] = await web3.PublicKey.findProgramAddress(
        [textEncoder.encode(ACCOUNT_SEED)],
        programID
    );
    return {publicKey: publicKey_, bump: bump_}
}

const publicKey = await _publicKey()

// get ledger state
export async function getCurrentState(program) {
    try {
        return await program.account.ledger.fetch(publicKey.publicKey);
    } catch (error) {
        console.log("could not get ledger: ", error);
    }
}
