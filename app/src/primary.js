import React from "react";
import {useWallet} from "@solana/wallet-adapter-react";
import {Connection} from "@solana/web3.js";
import {Program, Provider, web3} from "@project-serum/anchor";
import {useSnackbar} from "notistack";
import {BOSS, network, preflightCommitment, programID} from "./config";
import idl from "./idl.json";

function Primary({ledgerPubkey, ledger, setCurrentState, getCurrentState}) {
    const {enqueueSnackbar} = useSnackbar();
    const wallet = useWallet();

    // get provider
    async function getProvider() {
        const connection = new Connection(network, preflightCommitment);
        return new Provider(connection, wallet, preflightCommitment);
    }

    // Initialize the program
    async function purchase() {
        const provider = await getProvider();
        const program = new Program(idl, programID, provider);
        // rpc
        try {
            await program.rpc.purchasePrimary({
                accounts: {
                    user: provider.wallet.publicKey,
                    boss: BOSS,
                    ledger: ledgerPubkey,
                    systemProgram: web3.SystemProgram.programId,
                },
            });
            const account = await getCurrentState(program);
            setCurrentState(account)
            enqueueSnackbar("purchase success", {variant: "success"});
        } catch (error) {
            console.log("Transaction error: ", error);
            console.log(error.toString());
            enqueueSnackbar(`Error: ${error.toString()}`, {variant: "error"});
        }
    }

    function View() {
        if (wallet.connected) {
            // already init
            if (ledger.originalSupplyRemaining) {
                return (
                    <div>
                        <button onClick={purchase} className={"mt-6"}>
                            Purchase
                        </button>
                    </div>
                )
            } else {
                return null
            }
        } else {
            return null
        }
    }

    return (
        <View/>
    );
}

export default Primary;
