import {decodeBase64, encodeBase64, textEncoder} from "./util.js";
import * as nacl from "tweetnacl";


export async function sign(_phantom, user) {
    try {
        // build message
        const message = "ready for download"
        const encoded = textEncoder.encode(message)
        const signed = await _phantom.windowSolana.signMessage(encoded, "utf8");
        const _signed01 = {
            message: encodeBase64(encoded),
            signature: encodeBase64(signed.signature),
            user: encodeBase64(signed.publicKey.toBytes())
        }
        const _signedJson = JSON.stringify(_signed01)
        const _signed02 = JSON.parse(_signedJson)
        //const _verified = nacl.sign.detached.verify(encoded, signed.signature, signed.publicKey.toBytes())
        const _verified = nacl.sign.detached.verify(decodeBase64(_signed02.message), decodeBase64(_signed02.signature), decodeBase64(_signed02.user))
        const _json = JSON.stringify({foo: _verified})
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
