// Handler
import * as nacl from "tweetnacl";
import {Buffer} from "buffer";

exports.handler = async function (event, context) {
    console.log('## ENVIRONMENT VARIABLES: ' + serialize(process.env))
    console.log('## CONTEXT: ' + serialize(context))
    console.log('## EVENT: ' + serialize(event))
    const _verified = verify(event)
    try {
        return formatResponse(serialize({verified: _verified}))
    } catch (error) {
        return formatError(error)
    }
}

let formatResponse = function (body) {
    return {
        "statusCode": 200,
        "headers": {
            "Content-Type": "application/json"
        },
        "isBase64Encoded": false,
        "multiValueHeaders": {
            "Access-Control-Allow-Origin": ["*"],
        },
        "body": body
    }
}

let formatError = function (error) {
    return {
        "statusCode": error.statusCode,
        "headers": {
            "Content-Type": "text/plain",
            "x-amzn-ErrorType": error.code
        },
        "isBase64Encoded": false,
        "body": error.code + ": " + error.message
    }
}

let serialize = function (object) {
    return JSON.stringify(object, null, 2)
}

function decodeBase64(b64) {
    return new Uint8Array(Buffer.from(b64, 'base64'))
}

let verify = function (signedMessage) {
    return nacl.sign.detached.verify(decodeBase64(signedMessage.message), decodeBase64(signedMessage.signature), decodeBase64(signedMessage.user))
}
