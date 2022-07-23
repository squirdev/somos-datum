import assert from "assert";
import * as anchor from "@project-serum/anchor";
import {
    provider,
    program,
    createUser
} from "./util.ts";

describe("somos-datum", () => {
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    // UPLOAD ASSETS ///////////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    // init
    it("upload assets", async () => {
        // instantiate mint
        const mint = await createUser();
        // create assets
        const key = Buffer.from("k".repeat(184));
        const url = Buffer.from("u".repeat(78));
        // derive increment
        let pdaIncrement, _;
        [pdaIncrement, _] = await anchor.web3.PublicKey.findProgramAddress(
            [
                mint.key.publicKey.toBuffer(),
                provider.wallet.publicKey.toBuffer(),
            ],
            program.programId
        );
        // derive datum one
        let pdaOne;
        [pdaOne, _] = await anchor.web3.PublicKey.findProgramAddress(
            [
                mint.key.publicKey.toBuffer(),
                provider.wallet.publicKey.toBuffer(),
                Buffer.from([1])
            ],
            program.programId
        );
        // invoke rpc
        await program.methods
            .publishAssets(1, key, url)
            .accounts({
                datum: pdaOne,
                increment: pdaIncrement,
                mint: mint.key.publicKey,
                payer: provider.wallet.publicKey,
                systemProgram: anchor.web3.SystemProgram.programId,

            }).rpc();
        // fetch accounts
        let actualIncrement = await program.account.increment.fetch(
            pdaIncrement
        );
        const actualOne = await program.account.datum.fetch(
            pdaOne
        );
        // assertions
        assert.ok(actualIncrement.increment === 1);
        assert.ok(actualOne.seed === 1);
        // invoke again & fail
        let requiredError;
        try {
            // invoke rpc
            await program.methods
                .publishAssets(1, key, url)
                .accounts({
                    datum: pdaOne,
                    increment: pdaIncrement,
                    mint: mint.key.publicKey,
                    payer: provider.wallet.publicKey,
                    systemProgram: anchor.web3.SystemProgram.programId,

                }).rpc();
        } catch (error) {
            requiredError = true;
        }
        assert(requiredError);
        // invoke with skipped seed
        // derive datum three
        let pdaThree;
        [pdaThree, _] = await anchor.web3.PublicKey.findProgramAddress(
            [
                mint.key.publicKey.toBuffer(),
                provider.wallet.publicKey.toBuffer(),
                Buffer.from([3])
            ],
            program.programId
        );
        requiredError = false;
        try {
            // invoke rpc
            await program.methods
                .publishAssets(3, key, url)
                .accounts({
                    datum: pdaThree,
                    increment: pdaIncrement,
                    mint: mint.key.publicKey,
                    payer: provider.wallet.publicKey,
                    systemProgram: anchor.web3.SystemProgram.programId,

                }).rpc();
        } catch (error) {
            requiredError = true;
        }
        assert(requiredError);
        // invoke next seed
        // derive datum two
        let pdaTwo;
        [pdaTwo, _] = await anchor.web3.PublicKey.findProgramAddress(
            [
                mint.key.publicKey.toBuffer(),
                provider.wallet.publicKey.toBuffer(),
                Buffer.from([2])
            ],
            program.programId
        );
        // invoke rpc
        await program.methods
            .publishAssets(2, key, url)
            .accounts({
                datum: pdaTwo,
                increment: pdaIncrement,
                mint: mint.key.publicKey,
                payer: provider.wallet.publicKey,
                systemProgram: anchor.web3.SystemProgram.programId,

            }).rpc();
        // fetch accounts
        actualIncrement = await program.account.increment.fetch(
            pdaIncrement
        );
        const actualTwo = await program.account.datum.fetch(
            pdaTwo
        );
        // assertions
        assert.ok(actualIncrement.increment === 2);
        assert.ok(actualTwo.seed === 2);
    });
});
