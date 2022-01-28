/*! https://docs.phantom.app/ */

export async function getPhantom() {
    try {
        // connect
        const connection = await window.solana.connect();
        const pubKey = connection.publicKey
        console.log("phantom wallet connected");
        // send state to elm
        app.ports.connectSuccessListener.send(pubKey.toString())
        // return state to js
        return {windowSolana: window.solana, connection: connection}
    } catch (err) {
        console.log(err.message)
        // validate phantom install
        const isPhantomInstalled = window.solana && window.solana.isPhantom;
        if (!isPhantomInstalled) {
            // if phantom not intall open download link in new tab
            window.open("https://phantom.app/", "_blank");
        } else {
            // send err to elm
            app.ports.connectFailureListener.send(err.message)
        }
    }
}
