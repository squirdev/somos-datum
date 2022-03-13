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
let release01PubKey, _ = null;
app.ports.isConnectedSender.subscribe(async function (user) {
    // get provider & program
    const pp = getPP(phantom);
    // get program public key
    [release01PubKey, _] = await web3.PublicKey.findProgramAddress(
        [textEncoder.encode(ACCOUNT_SEED)],
        programID
    );
    // invoke state request & send response to elm
    await getCurrentState(pp.program, release01PubKey, user);
});

// init program
// TODO; elm sends PDA pubkey (clicked on by user)
app.ports.initProgramSender.subscribe(async function (user) {
    // get provider & program
    const pp = getPP(phantom)
    // invoke init: release 01
    await init(pp.program, pp.provider, release01PubKey, user, 0.025, 0.05, 100)
});

// primary purchase
app.ports.purchasePrimarySender.subscribe(async function (user) {
    // get provider & program
    const pp = getPP(phantom)
    // invoke purchase request
    await primary(pp.program, pp.provider, release01PubKey, user)
});

// sign message
app.ports.signMessageSender.subscribe(async function (user) {
    // get provider & program
    const pp = getPP(phantom)
    // invoke sign message
    await sign(phantom, user)
});

// open download url
app.ports.openDownloadUrlSender.subscribe(async function (json) {
    const obj = JSON.parse(json)
    // download
    download(obj.url)
});
