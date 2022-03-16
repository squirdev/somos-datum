import {web3} from "@project-serum/anchor";
import {getCurrentState} from "../state";
import {BOSS} from "../config";

export async function primary(program, provider, ledger, user) {
    try {
        await program.rpc.purchasePrimary({
            accounts: {
                user: provider.wallet.publicKey,
                boss: BOSS,
                ledger: ledger,
                systemProgram: web3.SystemProgram.programId,
            },
        });
        // get state after transaction
        await getCurrentState(program, ledger, user);
        // log success
        console.log("primary purchase success");
    } catch (error) {
        // log error
        console.log(error.toString());
        // send error to elm
        app.ports.purchasePrimaryFailureListener.send(error.message)
    }
}
