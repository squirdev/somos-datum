import {web3, BN} from "@project-serum/anchor";

export async function submit(program, provider, ledger, userJson) {
    // decode user
    const user = JSON.parse(userJson);
    const more = JSON.parse(user.more);
    // rpc
    try {
        await program.rpc.submitToEscrow(new BN(more.price), {
            accounts: {
                seller: provider.wallet.publicKey,
                ledger: ledger,
                systemProgram: web3.SystemProgram.programId,
            }
        });
        // send state to elm
        app.ports.getCurrentStateListener.send(userJson);
        // log success
        console.log("submit to escrow success");
    } catch (error) {
        // log error
        console.log(error.toString());
        // send error to elm
        app.ports.submitToEscrowFailureListener.send(error.message)
    }
}
