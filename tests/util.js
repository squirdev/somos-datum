import anchor from "@project-serum/anchor"
import {Buffer} from "buffer";

// Configure the client
export const provider = anchor.Provider.env();
anchor.setProvider(provider);
// fetch program
export const program = anchor.workspace.SomosSolana;

// create 2nd (or more) user
export async function createUser(airdropBalance) {
    airdropBalance = airdropBalance ?? 10 * anchor.web3.LAMPORTS_PER_SOL;
    let user = anchor.web3.Keypair.generate();
    let sig = await provider.connection.requestAirdrop(user.publicKey, airdropBalance);
    await provider.connection.confirmTransaction(sig);

    let wallet = new anchor.Wallet(user);
    let userProvider = new anchor.Provider(provider.connection, wallet, provider.opts);

    return {
        key: user,
        wallet,
        provider: userProvider,
    };
}

// create program from secondary user
export function programForUser(user) {
    return new anchor.Program(program.idl, program.programId, user.provider);
}

export function encodeBase64(u8) {
    return Buffer.from(u8).toString('base64')
}
