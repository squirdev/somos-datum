import React, {useEffect, useState} from "react";
import {useWallet} from "@solana/wallet-adapter-react";
import {Connection} from "@solana/web3.js";
import {Program, Provider, web3, BN} from "@project-serum/anchor";
import {useSnackbar} from "notistack";
import {network, preflightCommitment, programID} from "./config";
import idl from "./idl.json";
import {WalletMultiButton} from "@solana/wallet-adapter-material-ui";

function Init({ledgerPubkey, bump}) {
    const {enqueueSnackbar} = useSnackbar();
    const wallet = useWallet();

    async function getProvider() {
        const connection = new Connection(network, preflightCommitment);
        return new Provider(connection, wallet, preflightCommitment);
    }

    const [ledger, setLedger] = useState({
        originalSupplyRemaining: null,
        purchased: null,
        secondaryMarket: null
    });

    async function getCurrentState(program) {
        try {
            return await program.account.ledger.fetch(ledgerPubkey);
        } catch (error) {
            console.log("could not get ledger: ", error);
        }
    }

    function setCurrentState(account) {
        setLedger({
            originalSupplyRemaining: account.originalSupplyRemaining,
            purchased: account.purchased,
            secondaryMarket: account.secondaryMarket
        });
    }


    useEffect(() => {
        async function init() {
            const provider = await getProvider()
            const program = new Program(idl, programID, provider);
            const account = await getCurrentState(program)
            setCurrentState(account)
        }

        init()
    }, [ledgerPubkey, wallet]);

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
                    <div>
                        binary music data: {JSON.stringify(ledger, null, "\t")}
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
            <WalletMultiButton/>
            <View/>
        </div>
    );
}

export default Init;
