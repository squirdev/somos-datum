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
// const devnet = "https://psytrbhymqlkfrhudd.dev.genesysgo.net:8899/"
const mainnet = "https://ssc-dao.genesysgo.net/"
const connection = new web3.Connection(mainnet, preflightCommitment);
const provider = new Provider(connection, wallet, preflightCommitment);
// build program
const programID = new web3.PublicKey(idl.metadata.address);
const program = new Program(idl, programID, provider);
// get program public key
const textEncoder = new TextEncoder()
const ACCOUNT_SEED = "shortershortersh"
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
                const preSignedUrl = getPreSignedUrl()
                return formatResponse(serialize({user: body.userDecoded, url: preSignedUrl}))
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
        "multiValueHeaders": {
            "Access-Control-Allow-Origin": ["*"],
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
    const ownersList = await getOwnersList();
    const decodedUser = new web3.PublicKey(decodeBase64(user)).toString()
    return ownersList.includes(decodedUser)
}

async function getStatePubKeyAndBump() {
    [statePublicKey, bump] = await web3.PublicKey.findProgramAddress(
        [textEncoder.encode(ACCOUNT_SEED)],
        programID
    );
}

async function getOwnersList() {
    await getStatePubKeyAndBump()
    const state = await program.account.ledger.fetch(statePublicKey);
    return state.owners.map(_publicKey => _publicKey.toString());
}

function getPreSignedUrl() {
    const AWS = require('aws-sdk')
    const s3 = new AWS.S3()
    const bucket = 'somos-download-artifacts'
    const key = '01/01.zip'
    const signedUrlExpireSeconds = 60
    return s3.getSignedUrl('getObject', {
        Bucket: bucket,
        Key: key,
        Expires: signedUrlExpireSeconds
    })
}
