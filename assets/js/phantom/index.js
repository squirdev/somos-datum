/*! https://docs.phantom.app/ */

export async function getPhantom() {
    try {
        const connection = await window.solana.connect();
        const pubKey = connection.publicKey
        console.log("phantom wallet connected");
        console.log(pubKey)
        console.log(window.solana)
        console.log(window.solana._publicKey)
        console.log("phantom wallet connected");
        app.ports.connectSuccessListener.send(pubKey.toString())
        return {windowSolana: window.solana, connection: connection}
    } catch (err) {
        console.log(err.message)
        // validate phantom install
        const isPhantomInstalled = window.solana && window.solana.isPhantom;
        if (!isPhantomInstalled) {
            window.open("https://phantom.app/", "_blank");
        } else {
            app.ports.connectFailureListener.send(err.message)
        }
    }
}
