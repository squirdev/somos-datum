import {solanaWeb3} from "./index.js";
import {network, preflightCommitment} from "./config.js";

export const textEncoder = new TextEncoder()
export const connection = new solanaWeb3.Connection(network, preflightCommitment);