import {textEncoder} from "./util.js";
import * as nacl from "tweetnacl";

let foo = {
    "message": {
        "0": 114,
        "1": 101,
        "2": 97,
        "3": 100,
        "4": 121,
        "5": 32,
        "6": 102,
        "7": 111,
        "8": 114,
        "9": 32,
        "10": 100,
        "11": 111,
        "12": 119,
        "13": 110,
        "14": 108,
        "15": 111,
        "16": 97,
        "17": 100
    },
    "signature": {
        "type": "Buffer",
        "data": [85, 125, 49, 252, 195, 22, 144, 32, 111, 130, 51, 192, 7, 244, 108, 186, 222, 85, 110, 165, 1, 205, 75, 179, 134, 68, 189, 192, 231, 167, 200, 179, 224, 244, 79, 145, 112, 116, 101, 248, 27, 104, 74, 62, 249, 239, 126, 144, 164, 240, 156, 1, 134, 238, 68, 19, 158, 254, 219, 77, 93, 180, 125, 9]
    },
    "user": {
        "type": "Buffer",
        "data": [183, 76, 174, 229, 205, 18, 8, 209, 249, 27, 99, 15, 248, 80, 129, 233, 211, 34, 233, 161, 179, 74, 212, 207, 119, 208, 33, 106, 163, 11, 4, 31]
    }
}

export async function sign(_phantom, user) {
    try {
        // build message
        const message = "ready for download"
        const encoded = textEncoder.encode(message)
        const signed = await _phantom.windowSolana.signMessage(encoded, "utf8");
        const _signed = {
            message: encoded,
            signature: signed.signature,
            user: signed.publicKey.toBytes()
        }
        const _verified = nacl.sign.detached.verify(encoded, signed.signature, signed.publicKey.toBytes())
        // const _foo = nacl.sign.detached.verify(new Uint8Array(foo.message), signed.signature, signed.publicKey.toBytes())
        const _json = JSON.stringify(_signed)
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
