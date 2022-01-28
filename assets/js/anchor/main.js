import {Program, Provider, web3} from "@project-serum/anchor";
import {ACCOUNT_SEED, preflightCommitment, programID} from "./config";
import {connection, textEncoder} from "./util.js";
import {PhantomWallet} from "./wallet";
import {getPhantom} from "../phantom";
import idl from "./idl.json";
import {getCurrentState} from "./state";

// get program public key
let publicKey_, bump_ = null;
[publicKey_, bump_] = await web3.PublicKey.findProgramAddress(
    [textEncoder.encode(ACCOUNT_SEED)],
    programID
);
const programPublicKey = {publicKey: publicKey_, bump: bump_}


// get phantom
let phantom = null;
app.ports.connectSender.subscribe(async function () {
    phantom = await getPhantom()
});

// get provider
let provider = null;
app.ports.isConnectedSender.subscribe(async function () {
    // build wallet
    const wallet = new PhantomWallet(phantom)
    // set provider
    provider = new Provider(connection, wallet, preflightCommitment);
    // fetch current state of program
    // program
    const program = new Program(idl, programID, provider);
    // send current state of program to elm
    await getCurrentState(program, programPublicKey.publicKey)
});
