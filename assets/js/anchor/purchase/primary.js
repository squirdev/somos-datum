import {web3} from "@project-serum/anchor";
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
        // send state to elm
        app.ports.getCurrentStateListener.send(user);
        // log success
        console.log("primary purchase success");
    } catch (error) {
        // log error
        console.log(error.toString());
        // send error to elm
        app.ports.purchasePrimaryFailureListener.send(error.message)
    }
}
