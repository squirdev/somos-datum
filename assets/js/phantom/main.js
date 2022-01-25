/*! https://docs.phantom.app/ */
// validate phantom install
const isPhantomInstalled = window.solana && window.solana.isPhantom;
console.log(isPhantomInstalled)
// connect
app.ports.connectSender.subscribe(async function () {
    try {
        const connection = await window.solana.connect();
        const pubKey = connection.publicKey.toString()
        console.log("phantom wallet connected");
        console.log(connection)
        app.ports.connectSuccessListener.send(pubKey)
    } catch (err) {
        console.log(err.message)
        if (!isPhantomInstalled) {
            window.open("https://phantom.app/", "_blank");
        } else {
            app.ports.connectFailureListener.send(err.message)
        }
    }
});
