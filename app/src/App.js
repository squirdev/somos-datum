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
import Primary from "./primary";

// Nest app within <SnackbarProvider /> so that we can set up Snackbar notifications on Wallet errors
function Wrapped() {
    // logging context
    const {enqueueSnackbar} = useSnackbar();
    // state
    const [accountLookup, setAccountLookup] = useState({
        publicKey: null,
        bump: null,
    });
    // account pub key
    useEffect(() => {
        const init = async () => {
            let publicKey_, bump_ = null;
            [publicKey_, bump_] = await web3.PublicKey.findProgramAddress(
                [Buffer.from(ACCOUNT_SEED)],
                programID
            );
            setAccountLookup(
                {publicKey: publicKey_, bump: bump_}
            );
        };
        init();
    }, []);
    // wallet error
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
    // ledger state null
    const [ledger, setLedger] = useState({
        originalSupplyRemaining: null,
        purchased: null,
        secondaryMarket: null
    });
    // get ledger state
    async function getCurrentState(program) {
        try {
            return await program.account.ledger.fetch(accountLookup.publicKey);
        } catch (error) {
            console.log("could not get ledger: ", error);
        }
    }
    // set ledger state
    function setCurrentState(account) {
        setLedger({
            originalSupplyRemaining: account.originalSupplyRemaining,
            purchased: account.purchased,
            secondaryMarket: account.secondaryMarket
        });
    }
    // Wrap <Main /> within <WalletProvider /> so that we can access useWallet hook within Main
    return (
        <WalletProvider wallets={wallets} onError={onWalletError} autoConnect>
            <WalletDialogProvider>
                <Init
                    ledgerPubkey={accountLookup.publicKey}
                    bump={accountLookup.bump}
                    ledger={ledger}
                    setCurrentState={setCurrentState}
                    getCurrentState={getCurrentState}
                />
                <Primary
                    ledgerPubkey={accountLookup.publicKey}
                    ledger={ledger}
                    setCurrentState={setCurrentState}
                    getCurrentState={getCurrentState}
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
