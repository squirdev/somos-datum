import assert from "assert";
import anchor from "@project-serum/anchor";
import {provider, program, createUser, programForUser} from "./util.js";

describe("somos-solana", () => {
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    // PURCHASE (PRIMARY) //////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    // derive pda key
    let ledgerSeed = Buffer.from("hancockhancockha");
    let pdaLedgerPublicKey, _;
    before(async () => {
        [pdaLedgerPublicKey, _] =
            await anchor.web3.PublicKey.findProgramAddress(
                [ledgerSeed],
                program.programId
            );
    });
    // init
    it("initializes ledger", async () => {
        const price = 0.1 * anchor.web3.LAMPORTS_PER_SOL
        await program.rpc.initializeLedger(ledgerSeed, new anchor.BN(3), new anchor.BN(price), {
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
        assert.ok(actualLedger.originalSupplyRemaining === 3)
    });
    // purchase primary
    it("purchase primary", async () => {
        let purchaser = await createUser();
        let _program = programForUser(purchaser)
        let balance = await provider.connection.getBalance(provider.wallet.publicKey)
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
        assert.ok(actualLedger.originalSupplyRemaining === 2)
        assert.ok(diff === 100000000)
    });
    // purchase primary sold out
    it("purchase primary sold out", async () => {
        let purchaser = await createUser();
        let _program = programForUser(purchaser)
        let balance = await provider.connection.getBalance(provider.wallet.publicKey)
        await _program.rpc.purchasePrimary({
            accounts: {
                user: purchaser.key.publicKey,
                boss: provider.wallet.publicKey,
                ledger: pdaLedgerPublicKey,
                systemProgram: anchor.web3.SystemProgram.programId,
            }
        });
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
        assert.ok(actualLedger.originalSupplyRemaining === 0)
        assert.ok(diff === 200000000)
    });
    // throw error on sold out purchase
    it("purchase primary sold out throws error", async () => {
        let purchaser = await createUser();
        let _program = programForUser(purchaser)
        try {
            await _program.rpc.purchasePrimary({
                accounts: {
                    user: purchaser.key.publicKey,
                    boss: provider.wallet.publicKey,
                    ledger: pdaLedgerPublicKey,
                    systemProgram: anchor.web3.SystemProgram.programId,
                }
            });
        } catch (error) {
            console.log(error)
        }
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
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    // ESCROW //////////////////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    // derive pda key
    let escrowSeed = Buffer.from("grovergrovergrov");
    let pdaEscrowPublicKey, __;
    before(async () => {
        [pdaEscrowPublicKey, __] =
            await anchor.web3.PublicKey.findProgramAddress(
                [escrowSeed],
                program.programId
            );
    });
    // init
    it("initializes escrow", async () => {
        await program.rpc.initializeEscrow(escrowSeed, {
            accounts: {
                user: provider.wallet.publicKey,
                escrow: pdaEscrowPublicKey,
                systemProgram: anchor.web3.SystemProgram.programId,
            }
        });
        let actualEscrow = await program.account.escrow.fetch(
            pdaEscrowPublicKey
        );
        console.log(actualEscrow)
        // assertions
        assert.ok(actualEscrow.items.length === 0)
    });
    // submit
    it("submit to escrow", async () => {
        const price = 0.25 * anchor.web3.LAMPORTS_PER_SOL
        await program.rpc.submitToEscrow(new anchor.BN(price), {
            accounts: {
                seller: provider.wallet.publicKey,
                escrow: pdaEscrowPublicKey,
                ledger: pdaLedgerPublicKey,
                systemProgram: anchor.web3.SystemProgram.programId,
            }
        });
        let actualEscrow = await program.account.escrow.fetch(
            pdaEscrowPublicKey
        );
        console.log(actualEscrow)
        // assertions
        assert.ok(actualEscrow.items.length === 1)
    });
});
