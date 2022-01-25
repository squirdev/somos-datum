import React, {useEffect} from "react";
import {useWallet} from "@solana/wallet-adapter-react";
import {Connection} from "@solana/web3.js";
import {Program, Provider, web3, BN} from "@project-serum/anchor";
import {useSnackbar} from "notistack";
import {network, preflightCommitment, programID} from "./config";
import idl from "./idl.json";
import {WalletMultiButton} from "@solana/wallet-adapter-material-ui";

function Init({ledgerPubkey, bump, ledger, setCurrentState, getCurrentState}) {
    const {enqueueSnackbar} = useSnackbar();
    const wallet = useWallet();

    // get provider
    async function getProvider() {
        const connection = new Connection(network, preflightCommitment);
        return new Provider(connection, wallet, preflightCommitment);
    }

    // ledger state init
    useEffect(() => {
        async function init() {
            const provider = await getProvider()
            const program = new Program(idl, programID, provider);
            const account = await getCurrentState(program)
            setCurrentState(account)
        }

        init()
    }, [ledgerPubkey]);

    // Initialize the program
    async function initialize() {
        const provider = await getProvider();
        const program = new Program(idl, programID, provider);
        // rpc
        try {
            await program.rpc.initializeLedger(new BN(bump), {
                accounts: {
                    user: provider.wallet.publicKey,
                    ledger: ledgerPubkey,
                    systemProgram: web3.SystemProgram.programId,
                },
            });
            const account = await getCurrentState(program);
            setCurrentState(account)
            enqueueSnackbar("program initialized", {variant: "success"});
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
                    <div className={"columns"}>
                        <div className={"column is-6 has-border-2"}>
                            <h3>
                                Total Supply Remaining
                            </h3>
                            <div>
                                {ledger.originalSupplyRemaining.toString()}
                            </div>
                        </div>
                        <div className={"column is-6 has-border-2"}>
                            <h3>
                                Owners
                            </h3>
                            <ul>
                                {ledger.purchased.map(function (_publicKey) {
                                    return (<li className={"mb-2"}> {_publicKey.toString()}</li>)
                                })}
                            </ul>
                        </div>
                    </div>
                )
            } else {
                // init
                return (
                    <div>
                        <button onClick={initialize}>
                            Initialize Program!
                        </button>
                    </div>
                )
            }
        } else {
            return null
        }
    }

    return (
        <div>
            <WalletMultiButton className={"mb-6"}/>
            <View/>
        </div>
    );
}

export default Init;
