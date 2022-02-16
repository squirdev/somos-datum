import {web3} from "@project-serum/anchor";
import idl from "./idl.json";

export const preflightCommitment = "processed";
export const programID = new web3.PublicKey(idl.metadata.address);
export const ACCOUNT_SEED = Buffer.from("hancockhancockha");
export const BOSS = new web3.PublicKey("DLXRomaskStghSHAyoFZMKnFk1saLYDhYggW25Ze4jug")

const localnet = "http://127.0.0.1:8899";
// const devnet = web3.clusterApiUrl("devnet");
// const mainnet = web3.clusterApiUrl("mainnet-beta");
export const network = localnet;
