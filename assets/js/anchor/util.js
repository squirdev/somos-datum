import {web3, Provider} from "@project-serum/anchor";
import {network, preflightCommitment} from "./config.js";
import {getPhantom} from "../phantom";
import {ElmWallet} from "./wallet.ts";

export const textEncoder = new TextEncoder()
export const connection = new web3.Connection(network, preflightCommitment);

// get provider
export async function getProvider() {
    const phantom = getPhantom()
    const wallet = new ElmWallet(phantom)
    return new Provider(connection, wallet, preflightCommitment);
}