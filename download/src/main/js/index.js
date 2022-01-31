// Handler
import * as nacl from "tweetnacl";

exports.handler = async function (event, context) {
    console.log('## ENVIRONMENT VARIABLES: ' + serialize(process.env))
    console.log('## CONTEXT: ' + serialize(context))
    console.log('## EVENT: ' + serialize(event))
    let _verified = verify(foo)
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

let verify = function (signedMessage) {
    nacl.sign.detached.verify(signedMessage.message, signedMessage.signature, signedMessage.user)
}
