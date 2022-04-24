import {web3} from "@project-serum/anchor";

export const preflightCommitment = "processed";
export const programID = new web3.PublicKey("A2UL8cJAGZWetZJRgHizdGJGmsrCGR6ELBtwjj8kGeXp");
export const ACCOUNT_SEED_01 = Buffer.from("hancockhancockha");
export const ACCOUNT_SEED_02 = Buffer.from("robsonrobsonrobs");
export const BOSS = new web3.PublicKey("DLXRomaskStghSHAyoFZMKnFk1saLYDhYggW25Ze4jug")

// const localnet = "http://127.0.0.1:8899";
const devnet = web3.clusterApiUrl("devnet");
// const mainnet = web3.clusterApiUrl("mainnet-beta");
export const network = devnet;
