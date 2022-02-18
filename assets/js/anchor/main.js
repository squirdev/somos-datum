import {web3} from "@project-serum/anchor";
import {ACCOUNT_SEED, programID} from "./config";
import {getPP, textEncoder} from "./util.js";
import {getPhantom} from "../phantom";
import {getCurrentState} from "./state";
import {init} from "./init";
import {primary} from "./purchase/primary";
import {sign} from "./sign";
import {download} from "./download";


// get phantom
let phantom = null;
app.ports.connectSender.subscribe(async function () {
    phantom = await getPhantom()
});

// get current state as soon as user logs in
let statePublicKey, _ = null;
app.ports.isConnectedSender.subscribe(async function (user) {
    // get provider & program
    const pp = getPP(phantom);
    // get program public key
    [statePublicKey, _] = await web3.PublicKey.findProgramAddress(
        [textEncoder.encode(ACCOUNT_SEED)],
        programID
    );
    // invoke state request & send response to elm
    await getCurrentState(pp.program, statePublicKey, user);
});

// init program
app.ports.initProgramSender.subscribe(async function (user) {
    // get provider & program
    const pp = getPP(phantom)
    // invoke init request
    await init(pp.program, pp.provider, statePublicKey, user)
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
    // get provider & program
    const pp = getPP(phantom)
    // invoke state request & send response to elm
    const _state = await getCurrentState(pp.program, statePublicKey, user)
    // invoke sign message
    await sign(phantom, _state, user)
});

// open download url
app.ports.openDownloadUrlSender.subscribe(async function (json) {
    const obj = JSON.parse(json)
    // download
    download(obj.url)
});
