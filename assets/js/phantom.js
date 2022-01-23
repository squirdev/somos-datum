/*! https://docs.phantom.app/ */
const getProvider = () => {
    if ("solana" in window) {
        const provider = window.solana;
        if (provider.isPhantom) {
            return provider;
        }
    }
    window.open("https://phantom.app/", "_blank");
};

let connection = null;
app.ports.connectSender.subscribe(async function () {
    try {
        connection = await window.solana.connect();
    } catch (err) {
        // { code: 4001, message: 'User rejected the request.' }
        console.log(err.message)
        app.ports.connectFailureListener.send(err.message)
    }
});

window.solana.on("connect", () => {
    console.log("phantom wallet connected");
    app.ports.connectSuccessListener.send(true)
})
