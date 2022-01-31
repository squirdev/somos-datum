import {textEncoder} from "./util.js";

export async function sign(_phantom, user) {
    try {
        // build message
        const message = "ready for download"
        const encoded = textEncoder.encode(message)
        const signed = await _phantom.windowSolana.signMessage(encoded, "utf8");
        const first = signed.signature.data
        const second = signed.publicKey.toBytes().data
        const _signed = {
            first: first,
            second: second
        }
        const _json = JSON.stringify(signed)
        // send signature to elm
        app.ports.signMessageSuccessListener.send(_json)
        // log success
        console.log("sign message success & sent to elm");
    } catch (error) {
        // log error
        console.log(error.toString());
        // send error to elm
        app.ports.signMessageFailureListener.send(error.message)
    }
}
