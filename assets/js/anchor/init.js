import {web3, BN} from "@project-serum/anchor";
import {getCurrentState} from "./state";

export async function init(program, provider, statePublicKey, bump, user) {
    try {
        await program.rpc.initializeLedger(new BN(bump), {
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
