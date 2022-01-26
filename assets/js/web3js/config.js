import {solanaWeb3} from "./index.js";

export const preflightCommitment = "processed";
export const programID = new solanaWeb3.PublicKey("AgxH9tmJsyVHiN7c6mMwkPh77dzgQxWQv1o1GgeSHFtN");
export const ACCOUNT_SEED = "hancock"
export const BOSS = new solanaWeb3.PublicKey("DLXRomaskStghSHAyoFZMKnFk1saLYDhYggW25Ze4jug")

const localnet = "http://127.0.0.1:8899";
// const devnet = clusterApiUrl("devnet");
// const mainnet = clusterApiUrl("mainnet-beta");
export const network = localnet;
