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

// get provider
async function getProvider(wallet) {
    const connection = new Connection(network, preflightCommitment);
    return new Provider(connection, wallet, preflightCommitment);
}

// get ledger state
async function getCurrentState(program, accountLookup) {
    try {
        return await program.account.ledger.fetch(accountLookup.publicKey);
    } catch (error) {
        console.log("could not get ledger: ", error);
    }
}
