import {web3} from "@project-serum/anchor";
import {ACCOUNT_SEED, programID} from "./config";
import {getPP, textEncoder} from "./util.js";
import {getPhantom} from "../phantom";
import {getCurrentState} from "./state";
import {init} from "./init";
import {primary} from "./purchase/primary";
import {sign} from "./sign";

// get program public key
let statePublicKey, bump = null;
[statePublicKey, bump] = await web3.PublicKey.findProgramAddress(
    [textEncoder.encode(ACCOUNT_SEED)],
    programID
);

// get phantom
let phantom = null;
app.ports.connectSender.subscribe(async function () {
    phantom = await getPhantom()
});

// get current state as soon as user logs in
app.ports.isConnectedSender.subscribe(async function (user) {
    // get provider & program
    const pp = getPP(phantom)
    // invoke state request & send response to elm
    await getCurrentState(pp.program, statePublicKey, user)
});

// init program
app.ports.initProgramSender.subscribe(async function (user) {
    // get provider & program
    const pp = getPP(phantom)
    // invoke init request
    await init(pp.program, pp.provider, statePublicKey, bump, user)
});

// primary purchase
app.ports.purchasePrimarySender.subscribe(async function (user) {
    // get provider & program
    const pp = getPP(phantom)
    // invoke purchase request
    await primary(pp.program, pp.provider, statePublicKey, user)
});

// sign message
app.ports.signMessageSender.subscribe(async function (user) {
    // invoke sign message
    await sign(phantom, user)
});
