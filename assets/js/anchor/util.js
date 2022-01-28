import {Program, Provider, web3} from "@project-serum/anchor";
import {network, preflightCommitment, programID} from "./config.js";
import {PhantomWallet} from "./wallet";
import idl from "./idl.json";

export const textEncoder = new TextEncoder()
const connection = new web3.Connection(network, preflightCommitment);

// get provider & program
export function getPP(_phantom) {
    // build wallet
    const wallet = new PhantomWallet(_phantom)
    // set provider
    const provider = new Provider(connection, wallet, preflightCommitment);
    // fetch current state of program
    // program
    const program = new Program(idl, programID, provider);
    return {provider: provider, program: program}
}
