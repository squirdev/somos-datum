const assert = require("assert");
const anchor = require("@project-serum/anchor");
const {LAMPORTS_PER_SOL} = anchor.web3;

describe("somos-solana", () => {
    // Configure the client
    const provider = anchor.Provider.env();
    anchor.setProvider(provider);
    // fetch program
    const program = anchor.workspace.SomosSolana;

    // create 2nd (or more) user
    async function createUser(airdropBalance) {
        airdropBalance = airdropBalance ?? 10 * LAMPORTS_PER_SOL;
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
    function programForUser(user) {
        return new anchor.Program(program.idl, program.programId, user.provider);
    }

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
        let _provider = await createUser()
        let _program = programForUser(_provider)
        console.log(_provider.key.publicKey)
        await _program.rpc.initializePartitionOne(new anchor.BN(bumpOne), {
            accounts: {
                user: _provider.key.publicKey,
                partition: pdaOnePublicKey,
                systemProgram: anchor.web3.SystemProgram.programId,
            }
        });
        let actualOne = await _program.account.partition.fetch(
            pdaOnePublicKey
        );
        console.log(actualOne)
    });
    // init
    it("initializes partition two with bump", async () => {
        console.log(provider.wallet.publicKey)
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
                partitionOne: pdaOnePublicKey,
                partitionTwo: pdaTwoPublicKey,
                authority: provider.wallet.publicKey
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
