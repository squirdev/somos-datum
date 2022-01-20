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
    let pdaLedgerPublicKey, bumpLedger;
    before(async () => {
        [pdaLedgerPublicKey, bumpLedger] =
            await anchor.web3.PublicKey.findProgramAddress(
                [Buffer.from("hancock")],
                program.programId
            );
    });
    // init
    it("initializes ledger with bump", async () => {
        console.log(provider.wallet.publicKey)
        await program.rpc.initializeLedger(new anchor.BN(bumpLedger), {
            accounts: {
                user: provider.wallet.publicKey,
                ledger: pdaLedgerPublicKey,
                systemProgram: anchor.web3.SystemProgram.programId,
            }
        });
        let actualLedger = await program.account.ledger.fetch(
            pdaLedgerPublicKey
        );
        console.log(actualLedger)
        let balance = await provider.connection.getBalance(provider.wallet.publicKey);
        console.log(balance);
        // assertions
        assert.ok(actualLedger.originalSupplyRemaining === 1000)
    });
    // purchase primary
    it("purchase primary", async () => {
        let purchaser = await createUser();
        let _program = programForUser(purchaser)
        console.log(provider.wallet.publicKey)
        let balance = await provider.connection.getBalance(provider.wallet.publicKey)
        console.log(balance)
        await _program.rpc.purchasePrimary({
            accounts: {
                user: purchaser.key.publicKey,
                boss: provider.wallet.publicKey,
                ledger: pdaLedgerPublicKey,
                systemProgram: anchor.web3.SystemProgram.programId,
            }
        });
        let actualLedger = await _program.account.ledger.fetch(
            pdaLedgerPublicKey
        );
        console.log(actualLedger)
        const newBalance = await provider.connection.getBalance(provider.wallet.publicKey);
        const diff = newBalance - balance
        console.log(diff)
        console.log(newBalance)
        console.log(balance)
        // assertions
        assert.ok(actualLedger.originalSupplyRemaining === 999)
        assert.ok(diff === 2499968)
    });
    // failed purchase primary
    it("purchase primary failed without boss", async () => {
        let purchaser = await createUser();
        let _program = programForUser(purchaser)
        try {
            await _program.rpc.purchasePrimary({
                accounts: {
                    user: purchaser.key.publicKey,
                    boss: purchaser.key.publicKey,
                    ledger: pdaLedgerPublicKey,
                    systemProgram: anchor.web3.SystemProgram.programId,
                }
            });
        } catch (error) {
            console.log(error)
        }
    });

});
