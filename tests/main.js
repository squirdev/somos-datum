import assert from "assert";
import anchor from "@project-serum/anchor";
import {
    provider,
    program,
    createUser,
    programForUser,
    user02,
    program02,
    user03,
    program03,
    user04,
    program04
} from "./util.js";

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
        await program.rpc.initializeLedger(ledgerSeed, new anchor.BN(2), new anchor.BN(price), 0.10, {
            accounts: {
                user: provider.wallet.publicKey,
                ledger: pdaLedgerPublicKey,
                systemProgram: anchor.web3.SystemProgram.programId,
            }
        });
        const actualLedger = await program.account.ledger.fetch(
            pdaLedgerPublicKey
        );
        console.log(actualLedger)
        const balance = await provider.connection.getBalance(provider.wallet.publicKey);
        console.log(balance);
        // assertions
        assert.ok(actualLedger.originalSupplyRemaining === 2)
    });
    // purchase primary
    it("purchase primary", async () => {
        const balance = await provider.connection.getBalance(provider.wallet.publicKey)
        await program03.rpc.purchasePrimary({
            accounts: {
                buyer: user03.key.publicKey,
                recipient: user03.key.publicKey,
                boss: provider.wallet.publicKey,
                ledger: pdaLedgerPublicKey,
                systemProgram: anchor.web3.SystemProgram.programId,
            }
        });
        const actualLedger = await program03.account.ledger.fetch(
            pdaLedgerPublicKey
        );
        console.log(actualLedger)
        const newBalance = await provider.connection.getBalance(provider.wallet.publicKey);
        const diff = newBalance - balance
        console.log(diff)
        console.log(newBalance)
        console.log(balance)
        // assertions
        assert.ok(actualLedger.originalSupplyRemaining === 1)
        assert.ok(diff === 100000000)
    });
    // submit escrow
    it("submit to escrow should fail when primary market is not sold out", async () => {
        const price = 0.25 * anchor.web3.LAMPORTS_PER_SOL
        try {
            await program03.rpc.submitToEscrow(new anchor.BN(price), {
                accounts: {
                    seller: user03.key.publicKey,
                    ledger: pdaLedgerPublicKey,
                    systemProgram: anchor.web3.SystemProgram.programId,
                }
            });
        } catch (error) {
            console.log(error)
            assert.ok(error.code === 6004)
        }
        const actualLedger = await program.account.ledger.fetch(
            pdaLedgerPublicKey
        );
        console.log(actualLedger)
        // assertions
        assert.ok(actualLedger.escrow.length === 0)
    });
    // failed purchase primary
    it("purchase primary failed without boss", async () => {
        const purchaser = await createUser();
        const _program = programForUser(purchaser)
        try {
            await _program.rpc.purchasePrimary({
                accounts: {
                    buyer: purchaser.key.publicKey,
                    recipient: purchaser.key.publicKey,
                    boss: purchaser.key.publicKey,
                    ledger: pdaLedgerPublicKey,
                    systemProgram: anchor.web3.SystemProgram.programId,
                }
            });
        } catch (error) {
            assert.ok(error.code === 6001)
            console.log(error)
        }
    });
    // purchase primary
    it("purchase primary should fail when client tries to purchase again", async () => {
        try {
            await program03.rpc.purchasePrimary({
                accounts: {
                    buyer: user03.key.publicKey,
                    recipient: user03.key.publicKey,
                    boss: provider.wallet.publicKey,
                    ledger: pdaLedgerPublicKey,
                    systemProgram: anchor.web3.SystemProgram.programId,
                }
            });
        } catch (error) {
            assert.ok(error.code === 6005)
            console.log(error)
        }
        const actualLedger = await program03.account.ledger.fetch(
            pdaLedgerPublicKey
        );
        console.log(actualLedger)
        // assertions
        assert.ok(actualLedger.originalSupplyRemaining === 1)
    });
    // purchase primary
    it("purchase primary for someone else", async () => {
        const balance = await provider.connection.getBalance(provider.wallet.publicKey)
        await program03.rpc.purchasePrimary({
            accounts: {
                buyer: user03.key.publicKey,
                recipient: user02.key.publicKey,
                boss: provider.wallet.publicKey,
                ledger: pdaLedgerPublicKey,
                systemProgram: anchor.web3.SystemProgram.programId,
            }
        });
        const actualLedger = await program02.account.ledger.fetch(
            pdaLedgerPublicKey
        );
        console.log(actualLedger)
        const owners = actualLedger.owners.map(_publicKey => _publicKey.toString())
        const newBalance = await provider.connection.getBalance(provider.wallet.publicKey);
        const diff = newBalance - balance
        console.log(diff)
        console.log(newBalance)
        console.log(balance)
        // assertions
        assert.ok(owners.includes(user02.key.publicKey.toString()))
        assert.ok(actualLedger.originalSupplyRemaining === 0)
        assert.ok(diff === 100000000)
    });
    // throw error on sold out purchase
    it("purchase primary sold out throws error", async () => {
        const purchaser = await createUser();
        const _program = programForUser(purchaser)
        try {
            await _program.rpc.purchasePrimary({
                accounts: {
                    buyer: purchaser.key.publicKey,
                    recipient: purchaser.key.publicKey,
                    boss: provider.wallet.publicKey,
                    ledger: pdaLedgerPublicKey,
                    systemProgram: anchor.web3.SystemProgram.programId,
                }
            });
        } catch (error) {
            assert.ok(error.code === 6000)
            console.log(error)
        }
    });
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    // ESCROW //////////////////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    // submit
    it("submit to escrow", async () => {
        const price = 0.25 * anchor.web3.LAMPORTS_PER_SOL
        await program02.rpc.submitToEscrow(new anchor.BN(price), {
            accounts: {
                seller: user02.key.publicKey,
                ledger: pdaLedgerPublicKey,
                systemProgram: anchor.web3.SystemProgram.programId,
            }
        });
        const actualLedger = await program.account.ledger.fetch(
            pdaLedgerPublicKey
        );
        console.log(actualLedger)
        // assertions
        assert.ok(actualLedger.escrow.length === 1)
    });
    // submit
    it("submit to escrow failed without ledger ownership", async () => {
        const seller = await createUser();
        const _program = programForUser(seller)
        const price = 0.25 * anchor.web3.LAMPORTS_PER_SOL
        try {
            await _program.rpc.submitToEscrow(new anchor.BN(price), {
                accounts: {
                    seller: seller.key.publicKey,
                    ledger: pdaLedgerPublicKey,
                    systemProgram: anchor.web3.SystemProgram.programId,
                }
            });
        } catch (error) {
            assert.ok(error.code === 6002)
            console.log(error);
        }
        const actualLedger = await _program.account.ledger.fetch(
            pdaLedgerPublicKey
        );
        // assertions
        assert.ok(actualLedger.escrow.length === 1)
    });
    // submit
    it("submit to escrow failed when item already in escrow", async () => {
        const price = 0.25 * anchor.web3.LAMPORTS_PER_SOL
        try {
            await program02.rpc.submitToEscrow(new anchor.BN(price), {
                accounts: {
                    seller: user02.key.publicKey,
                    ledger: pdaLedgerPublicKey,
                    systemProgram: anchor.web3.SystemProgram.programId,
                }
            });
        } catch (error) {
            assert.ok(error.code === 6006)
            console.log(error);
        }
        const actualLedger = await program02.account.ledger.fetch(
            pdaLedgerPublicKey
        );
        // assertions
        assert.ok(actualLedger.escrow.length === 1)
    });
    // purchase secondary
    it("fail on purchase secondary when item is not on escrow", async () => {
        const buyer = await createUser();
        const _program = programForUser(buyer)
        const seller = user03.key.publicKey; // user03 never submitted for escrow
        const boss = provider.wallet.publicKey;
        try {
            await _program.rpc.purchaseSecondary({
                accounts: {
                    buyer: buyer.key.publicKey,
                    seller: seller,
                    boss: boss,
                    ledger: pdaLedgerPublicKey,
                    systemProgram: anchor.web3.SystemProgram.programId,
                }
            });
        } catch (error) {
            assert.ok(error.code === 6003)
            console.log(error);
        }
    });
    // purchase secondary
    it("purchase secondary", async () => {
        // players
        const buyer = user04.key.publicKey;
        const seller = user02.key.publicKey;
        const boss = provider.wallet.publicKey;
        // balances
        const balanceSeller = await provider.connection.getBalance(seller);
        const balanceBoss = await provider.connection.getBalance(boss);
        // success
        await program04.rpc.purchaseSecondary({
            accounts: {
                buyer: buyer,
                seller: seller,
                boss: boss,
                ledger: pdaLedgerPublicKey,
                systemProgram: anchor.web3.SystemProgram.programId,
            }
        });
        // PDAs
        const actualLedger = await program.account.ledger.fetch(
            pdaLedgerPublicKey
        )
        console.log(actualLedger)
        // balances
        const newBalanceSeller = await provider.connection.getBalance(seller);
        const newBalanceBoss = await provider.connection.getBalance(boss);
        // assertions
        assert.ok(actualLedger.escrow.length === 0)
        const owners = actualLedger.owners.map(_publicKey => _publicKey.toString())
        assert.ok(owners.includes(buyer.toString()))
        assert.ok(owners.filter(pk => pk === seller.toString()).length === 0)
        assert.ok(newBalanceSeller - balanceSeller === 225000000)
        assert.ok(newBalanceBoss - balanceBoss === 25000000)
    });
    // purchase secondary
    it("purchase secondary should fail when client tries to purchase again", async () => {
        // players
        const buyer = user04.key.publicKey;
        const seller = user02.key.publicKey;
        const boss = provider.wallet.publicKey;
        // failure
        try {
            await program04.rpc.purchaseSecondary({
                accounts: {
                    buyer: buyer,
                    seller: seller,
                    boss: boss,
                    ledger: pdaLedgerPublicKey,
                    systemProgram: anchor.web3.SystemProgram.programId,
                }
            });
        } catch (error) {
            console.log(error);
            assert.ok(error.code === 6005)
        }
        // PDAs
        const actualLedger = await program.account.ledger.fetch(
            pdaLedgerPublicKey
        )
        console.log(actualLedger)
        // assertions
        assert.ok(actualLedger.escrow.length === 0)
    });
    // submit
    it("submit to escrow after purchasing secondary", async () => {
        const price = 0.55 * anchor.web3.LAMPORTS_PER_SOL
        await program04.rpc.submitToEscrow(new anchor.BN(price), {
            accounts: {
                seller: user04.key.publicKey,
                ledger: pdaLedgerPublicKey,
                systemProgram: anchor.web3.SystemProgram.programId,
            }
        });
        const actualLedger = await program.account.ledger.fetch(
            pdaLedgerPublicKey
        );
        console.log(actualLedger)
        // assertions
        assert.ok(actualLedger.escrow.length === 1)
    });
    // remove
    it("remove from escrow", async () => {
        await program04.rpc.removeFromEscrow({
            accounts: {
                seller: user04.key.publicKey,
                ledger: pdaLedgerPublicKey,
                systemProgram: anchor.web3.SystemProgram.programId,
            }
        });
        const actualLedger = await program.account.ledger.fetch(
            pdaLedgerPublicKey
        );
        console.log(actualLedger)
        // assertions
        assert.ok(actualLedger.escrow.length === 0)
    });
    // remove
    it("remove from escrow fails when item not on escrow", async () => {
        try {
            await program04.rpc.removeFromEscrow({
                accounts: {
                    seller: user04.key.publicKey,
                    ledger: pdaLedgerPublicKey,
                    systemProgram: anchor.web3.SystemProgram.programId,
                }
            });
        } catch (error) {
            console.log(error);
            assert.ok(error.code === 6003)
        }
        const actualLedger = await program.account.ledger.fetch(
            pdaLedgerPublicKey
        );
        console.log(actualLedger)
        // assertions
        assert.ok(actualLedger.escrow.length === 0)
    });
});
