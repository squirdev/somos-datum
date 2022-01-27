/*! https://docs.phantom.app/ */
// validate phantom install
import {getPhantom} from "./index.js";

// connect
app.ports.connectSender.subscribe(async function () {
    await getPhantom()
});
