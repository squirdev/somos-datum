import {web3} from "@project-serum/anchor";
import {ACCOUNT_SEED, programID} from "./config";
import {getPP, textEncoder} from "./util.js";
import {getPhantom} from "../phantom";
import {getLedger, sendLedgers} from "./state";
import {init} from "./init";
import {primary} from "./purchase/primary";
import {sign} from "./sign";
import {download} from "./download";
import {submit} from "./escrow";
import {secondary} from "./purchase/secondary";


// TODO; move this file to root
// get phantom
let phantom = null;
let release01PubKey, _ = null;
app.ports.connectSender.subscribe(async function (user) {
    // get program public key
    [release01PubKey, _] = await web3.PublicKey.findProgramAddress(
        [textEncoder.encode(ACCOUNT_SEED)],
        programID
    );
    // get phantom
    phantom = await getPhantom(user);
});

// get current state as soon as user logs in
app.ports.getCurrentStateSender.subscribe(async function (user) {
    // get provider & program
    const pp = getPP(phantom);
    // invoke state request & send response to elm
    const ledgerOne = await getLedger(pp.program, release01PubKey);
    await sendLedgers(user, ledgerOne);
});

// init program
// TODO; elm sends PDA pubkey (clicked on by user)
app.ports.initProgramSender.subscribe(async function (user) {
    // get provider & program
    const pp = getPP(phantom);
    // invoke init: release 01
    await init(pp.program, pp.provider, release01PubKey, user, 1, 0.025, 0.05);
});

// primary purchase
app.ports.purchasePrimarySender.subscribe(async function (user) {
    // get provider & program
    const pp = getPP(phantom);
    // invoke purchase request
    await primary(pp.program, pp.provider, release01PubKey, user);
});

// submit to escrow
app.ports.submitToEscrowSender.subscribe(async function (user) {
    // get provider & program
    const pp = getPP(phantom);
    // invoke submit to escrow
    await submit(pp.program, pp.provider, release01PubKey, user);
});

// secondary purchase
app.ports.purchaseSecondarySender.subscribe(async function (user) {
    // get provider & program
    const pp = getPP(phantom);
    // invoke purchase request
    await secondary(pp.program, pp.provider, release01PubKey, user);
});

// sign message
app.ports.signMessageSender.subscribe(async function (user) {
    // invoke sign message
    await sign(phantom, user);
});

// open download url
app.ports.openDownloadUrlSender.subscribe(async function (json) {
    const obj = JSON.parse(json);
    // download
    download(obj.url);
});
