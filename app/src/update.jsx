import React, {useState} from "react";
import {useWallet} from "@solana/wallet-adapter-react";
import {Connection} from "@solana/web3.js";
import {Program, Provider} from "@project-serum/anchor";
import {useSnackbar} from "notistack";
import {preflightCommitment, programID} from "./config";
import idl from "./idl.json";

const anchor = require("@project-serum/anchor");

function Update({network, musicAccountPublicKey}) {
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

    async function update() {
        const provider = await getProvider();
        const program = new Program(idl, programID, provider);
        // fake binary music data
        const fakeBinaryMusicData = new anchor.BN(Math.random() * 100)
        // rpc
        try {
            await program.rpc.update(fakeBinaryMusicData, {
                accounts: {
                    musicAccount: musicAccountPublicKey
                },
            });
            const musicAccount = await program.account.music.fetch(musicAccountPublicKey);
            setMusic({
                binary: musicAccount.binary
            });
            enqueueSnackbar("program updated", {variant: "success"});
        } catch (error) {
            console.log("Transaction error: ", error);
            console.log(error.toString());
            enqueueSnackbar(`Error: ${error.toString()}`, {variant: "error"});
        }
    }

    function MaybeInitButton() {
        if (wallet.connected) {
            return (
                <div>
                    <button onClick={update}>
                        update program
                    </button>
                    <div>
                        binary music data: {JSON.stringify(music, null, "\t")}
                    </div>
                </div>
            )
        } else {
            return null
        }
    }

    return (
        <div>
            <MaybeInitButton/>
        </div>
    );
}

export default Update;
