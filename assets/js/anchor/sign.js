import {web3} from "@project-serum/anchor";
import {encodeBase64, textEncoder} from "./util.js";

// TODO; move to phantom dir
export async function sign(_phantom, user) {
    try {
        // build message
        const message = "ready for download"
        const encoded = textEncoder.encode(message)
        const signed = await _phantom.windowSolana.signMessage(encoded, "utf8");
        // build json
        const signedObj = {
            message: encodeBase64(encoded),
            signature: encodeBase64(signed.signature),
            user: encodeBase64(new web3.PublicKey(user).toBytes()),
            userDecoded: user
        }
        const signedJson = JSON.stringify(signedObj)
        // send signature to elm
        app.ports.signMessageSuccessListener.send(signedJson)
        // log success
        console.log("sign message success & sent to elm");
    } catch (error) {
        // log error
        console.log(error.toString());
        // send error to elm
        app.ports.signMessageFailureListener.send(error.message)
    }
}
