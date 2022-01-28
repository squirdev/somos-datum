import {web3} from "@project-serum/anchor";
import {network, preflightCommitment} from "./config.js";

export const textEncoder = new TextEncoder()
export const connection = new web3.Connection(network, preflightCommitment);
