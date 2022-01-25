// `solanaWeb3` is provided in the global namespace by the `solanaWeb3.min.js` script bundle.
import {network, preflightCommitment} from "./config.js";

export const textEncoder = new TextEncoder()
export const connection = new solanaWeb3.Connection(network, preflightCommitment);
