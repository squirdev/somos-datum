const assert = require("assert");
const anchor = require("@project-serum/anchor");

describe("somos-solana", () => {
    // Configure the client
    const provider = anchor.Provider.env();
    anchor.setProvider(provider);
    // fetch program
    const program = anchor.workspace.SomosSolana;
    // derive pda key
    let pdaOnePublicKey, bumpOne;
    before(async () => {
        [pdaOnePublicKey, bumpOne] =
            await anchor.web3.PublicKey.findProgramAddress(
                [Buffer.from("hemingway")],
                program.programId
            );
    });
    // derive pda key
    let pdaTwoPublicKey, bumpTwo;
    before(async () => {
        [pdaTwoPublicKey, bumpTwo] =
            await anchor.web3.PublicKey.findProgramAddress(
                [Buffer.from("miller")],
                program.programId
            );
    });
    // data
    let dataOne = "12345"
    let dataTwo = "678910"
    // init
    it("initializes partition one with bump", async () => {
        await program.rpc.initializePartitionOne(new anchor.BN(bumpOne), {
            accounts: {
                user: provider.wallet.publicKey,
                partition: pdaOnePublicKey,
                systemProgram: anchor.web3.SystemProgram.programId,
            }
        });
        let actualOne = await program.account.partition.fetch(
            pdaOnePublicKey
        );
        console.log(actualOne)
    });
    // init
    it("initializes partition two with bump", async () => {
        await program.rpc.initializePartitionTwo(new anchor.BN(bumpTwo), {
            accounts: {
                user: provider.wallet.publicKey,
                partition: pdaTwoPublicKey,
                systemProgram: anchor.web3.SystemProgram.programId,
            }
        });
        let actualTwo = await program.account.partition.fetch(
            pdaTwoPublicKey
        );
        console.log(actualTwo)
    });
    // update
    it("updates both partitions with data", async () => {
        await program.rpc.update(dataOne, dataTwo, {
            accounts: {
                user: provider.wallet.publicKey,
                partitionOne: pdaOnePublicKey,
                partitionTwo: pdaTwoPublicKey,
                systemProgram: anchor.web3.SystemProgram.programId,
            }
        });
        let actualOne = await program.account.partition.fetch(
            pdaOnePublicKey
        );
        let actualTwo = await program.account.partition.fetch(
            pdaTwoPublicKey
        );
        console.log(actualOne)
        console.log(actualTwo)
    });

});
