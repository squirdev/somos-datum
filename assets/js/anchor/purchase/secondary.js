import {web3} from "@project-serum/anchor";
import {BOSS} from "../config";

export async function secondary(program, provider, ledger, userJson) {
    // decode user
    const user = JSON.parse(userJson);
    const more = JSON.parse(user.more);
    const seller = new web3.PublicKey(more.seller)
    // rpc
    try {
        await program.rpc.purchaseSecondary(seller, {
            accounts: {
                buyer: provider.wallet.publicKey,
                seller: seller,
                boss: BOSS,
                ledger: ledger,
                systemProgram: web3.SystemProgram.programId,
            },
        });
        // send state to elm
        app.ports.getCurrentStateListener.send(user);
        // log success
        console.log("secondary purchase success");
    } catch (error) {
        // log error
        console.log(error.toString());
        // send error to elm
        app.ports.purchaseSecondaryFailureListener.send(error.message)
    }
}
