// Handler
const nacl = require("tweetnacl");

const {Buffer} = require("buffer");
const {web3, Wallet, Program, Provider} = require("@project-serum/anchor");
const fs = require('fs')
let idl = JSON.parse(fs.readFileSync('./idl.json', 'utf-8'))

// generate keypair
const keyPair = web3.Keypair.generate()
// build wallet
const wallet = new Wallet(keyPair)
// build provider
const preflightCommitment = "processed";
const devnet = "https://psytrbhymqlkfrhudd.dev.genesysgo.net:8899/"
// const mainnet = "https://ssc-dao.genesysgo.net/"
const connection = new web3.Connection(devnet, preflightCommitment);
const provider = new Provider(connection, wallet, preflightCommitment);
// build program
const programID = new web3.PublicKey(idl.metadata.address);
const program = new Program(idl, programID, provider);
// get program public key
const textEncoder = new TextEncoder()
const ACCOUNT_SEED = "hancock"
let statePublicKey, bump = null;

exports.handler = async function (event, context) {
    console.log('## ENVIRONMENT VARIABLES: ' + serialize(process.env))
    console.log('## CONTEXT: ' + serialize(context))
    console.log('## EVENT: ' + serialize(event))
    try {
        const body = JSON.parse(event.body)
        const verified01 = verifySignature(body)
        if (verified01) {
            const verified02 = await verifyOwnership(body.user)
            if (verified02) {
                return formatResponse(serialize({verified: true}))
            } else {
                return formatError({statusCode: "401", code: "401", message: "cannot prove ownership of user"})
            }
        } else {
            return formatError({statusCode: "401", code: "401", message: "digital signature invalid"})
        }
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

function verifySignature(signedMessage) {
    return nacl.sign.detached.verify(decodeBase64(signedMessage.message), decodeBase64(signedMessage.signature), decodeBase64(signedMessage.user))
}

async function verifyOwnership(user) {
    const purchasedList = await getPurchasedList();
    const decodedUser = new web3.PublicKey(decodeBase64(user)).toString()
    return purchasedList.includes(decodedUser)
}

async function getStatePubKeyAndBump() {
    [statePublicKey, bump] = await web3.PublicKey.findProgramAddress(
        [textEncoder.encode(ACCOUNT_SEED)],
        programID
    );
}

async function getPurchasedList() {
    await getStatePubKeyAndBump()
    const state = await program.account.ledger.fetch(statePublicKey);
    return state.purchased.map(_publicKey => _publicKey.toString());
}
