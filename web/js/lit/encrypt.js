import LitJsSdk from 'lit-js-sdk'
import {chain} from "./config";
import {solRpcConditions} from "./util";


export async function encrypt(files, args) {
    // build client
    const client = new LitJsSdk.LitNodeClient();
    // await for connection
    console.log("connecting to LIT network");
    await client.connect();
    // invoke signature
    console.log("invoking signature request");
    const authSig = await LitJsSdk.checkAndSignAuthMessage({chain: chain});
    // encrypt
    console.log("encrypting files");
    const {encryptedZip, symmetricKey} = await LitJsSdk.zipAndEncryptFiles(
        files
    );
    // push key to network
    console.log("pushing key to network");
    const encryptedSymmetricKey = await client.saveEncryptionKey({
        solRpcConditions: solRpcConditions(args),
        chain: chain,
        authSig: authSig,
        symmetricKey: symmetricKey,
        permanent: true
    });
    return {encryptedSymmetricKey, encryptedZip}
}
