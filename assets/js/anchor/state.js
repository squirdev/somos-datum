import {web3} from "@project-serum/anchor";
import {ACCOUNT_SEED, programID} from "./config.js";
import {textEncoder} from "./util.js";

export async function publicKey() {
    let publicKey_, bump_ = null;
    [publicKey_, bump_] = await web3.PublicKey.findProgramAddress(
        [textEncoder.encode(ACCOUNT_SEED)],
        programID
    );
    return {publicKey: publicKey_, bump: bump_}
}
