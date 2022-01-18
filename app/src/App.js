import Init from "./init";
import React, {useCallback, useEffect, useState} from "react";
import {
    ConnectionProvider,
    WalletProvider,
} from "@solana/wallet-adapter-react";
import {WalletDialogProvider} from "@solana/wallet-adapter-material-ui";
import {SnackbarProvider, useSnackbar} from "notistack";
import {web3} from "@project-serum/anchor";
import {programID, network, wallets, ACCOUNT_SEED} from "./config";
import Update from "./update";

// Nest app within <SnackbarProvider /> so that we can set up Snackbar notifications on Wallet errors
function Wrapped() {
    const {enqueueSnackbar} = useSnackbar();
    const [musicAccount, setMusicAccount] = useState({
        publicKey: null,
        bump: null,
    });

    useEffect(() => {
        const getMusicAccount = async () => {
            let publicKey_, bump_ = null;
            [publicKey_, bump_] = await web3.PublicKey.findProgramAddress(
                [Buffer.from("somos_seed")],
                programID
            );
            setMusicAccount(
                {publicKey: publicKey_, bump: bump_}
            );
        };
        getMusicAccount();
    }, []);

    const onWalletError = useCallback(
        (error) => {
            enqueueSnackbar(
                error.message ? `${error.name}: ${error.message}` : error.name,
                {variant: "error"}
            );
            console.error(error);
        },
        [enqueueSnackbar]
    );

    // Wrap <Main /> within <WalletProvider /> so that we can access useWallet hook within Main
    return (
        <WalletProvider wallets={wallets} onError={onWalletError} autoConnect>
            <WalletDialogProvider>
                <Init
                    network={network}
                    musicAccountPublicKey={musicAccount.publicKey}
                    bump={musicAccount.bump}
                />
                <Update
                    network={network}
                    musicAccountPublicKey={musicAccount.publicKey}
                />
            </WalletDialogProvider>
        </WalletProvider>
    );
}

export default function App() {
    return (
        <section className={"hero is-fullheight has-black"}>
            <div className={"hero-body"}>
                <div className={"container"}>
                    <SnackbarProvider>
                        <ConnectionProvider endpoint={network}>
                            <Wrapped/>
                        </ConnectionProvider>
                    </SnackbarProvider>
                </div>
            </div>
        </section>
    );
}
