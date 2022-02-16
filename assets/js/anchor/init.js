import {web3, BN} from "@project-serum/anchor";
import {getCurrentState} from "./state";
import {ACCOUNT_SEED} from "./config";

export async function init(program, provider, statePublicKey, bump, user) {
    try {
        const price = 0.025 * web3.LAMPORTS_PER_SOL
        await program.rpc.initializeLedger(ACCOUNT_SEED, new BN(bump), new BN(100), new BN(price), {
            accounts: {
                user: provider.wallet.publicKey,
                ledger: statePublicKey,
                systemProgram: web3.SystemProgram.programId,
            },
        });
        // get state after transaction
        await getCurrentState(program, statePublicKey, user);
        // log success
        console.log("program init success");
    } catch (error) {
        // log error
        console.log(error.toString());
        // send error to elm
        app.ports.initProgramFailureListener.send(error.message)
    }
}
