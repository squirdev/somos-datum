import {Keypair, PublicKey, Transaction} from "@solana/web3.js";
import {Wallet} from "@project-serum/anchor";

export class ElmWallet implements Wallet {

    constructor(readonly phantom: any) {
    }

    async signTransaction(tx: Transaction): Promise<Transaction> {
        return this.phantom.windowSolana.signTransaction(tx);
    }

    async signAllTransactions(txs: Transaction[]): Promise<Transaction[]> {
        return txs.map((t) => {
            this.phantom.windowSolana.signTransaction(t);
            return t;
        });
    }

    readonly payer: Keypair;

    get publicKey(): PublicKey {
        return this.phantom.connection.publicKey;
    }

}
