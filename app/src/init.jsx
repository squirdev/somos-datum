import React, {useState} from "react";
import {useWallet} from "@solana/wallet-adapter-react";
import {Connection} from "@solana/web3.js";
import {Program, Provider, web3, BN} from "@project-serum/anchor";
import {useSnackbar} from "notistack";
import {preflightCommitment, programID} from "./config";
import idl from "./idl.json";
import {WalletMultiButton} from "@solana/wallet-adapter-material-ui";

const anchor = require("@project-serum/anchor");

function Init({network, musicAccountPublicKey, bump}) {
    const {enqueueSnackbar} = useSnackbar();
    const wallet = useWallet();

    async function getProvider() {
        const connection = new Connection(network, preflightCommitment);
        const provider = new Provider(connection, wallet, preflightCommitment);
        return provider;
    }

    const [music, setMusic] = useState({
        binary: null
    });

    // Initialize the program
    async function initialize() {
        const provider = await getProvider();
        const program = new Program(idl, programID, provider);
        // fake binary music data
        const fakeBinaryMusicData = new anchor.BN(1234)
        // rpc
        try {
            await program.rpc.initialize(new BN(bump), fakeBinaryMusicData, {
                accounts: {
                    user: provider.wallet.publicKey,
                    musicAccount: musicAccountPublicKey,
                    systemProgram: web3.SystemProgram.programId,
                },
            });
            const musicAccount = await program.account.music.fetch(musicAccountPublicKey);
            setMusic({
                binary: musicAccount.binary
            });
            enqueueSnackbar("program initialized", {variant: "success"});
        } catch (error) {
            console.log("Transaction error: ", error);
            console.log(error.toString());
            enqueueSnackbar(`Error: ${error.toString()}`, {variant: "error"});
        }
    }

    return (
        <div >
            <WalletMultiButton/>
            <button onClick={initialize()}>
                Initialize Program!
            </button>
            <div >
                Binary Music Data: {music.binary.toString()}
            </div>
        </div>
    );
}

export default Init;
