const assert = require("assert");
const anchor = require("@project-serum/anchor");

describe("somos-solana", () => {
    // Configure the client
    const provider = anchor.Provider.env();
    anchor.setProvider(provider);

    const program = anchor.workspace.SomosSolana;

    let musicAccount, bump;
    before(async () => {
        [musicAccount, bump] =
            await anchor.web3.PublicKey.findProgramAddress(
                [Buffer.from("somos_seed")],
                program.programId
            );
    });

    let fakeBinaryMusicData = new anchor.BN(1234)

    it("initializes music account with binary data & bump", async () => {
        await program.rpc.initialize(new anchor.BN(bump), fakeBinaryMusicData, {
            accounts: {
                user: provider.wallet.publicKey,
                musicAccount: musicAccount,
                systemProgram: anchor.web3.SystemProgram.programId,
            }
        });
        let actual = await program.account.music.fetch(
            musicAccount
        );
        console.log(actual)
        assert.equal(actual.binary.toNumber(), fakeBinaryMusicData.toNumber());
        assert.equal(actual.bump, bump);
    });

    let moreFakeBinaryMusicData = new anchor.BN(4321)

    it("updates music account with new binary data", async () => {
        await program.rpc.update(moreFakeBinaryMusicData, {
            accounts: {
                musicAccount: musicAccount
            }
        })
        let actual = await program.account.music.fetch(
            musicAccount
        )
        console.log(actual)
        assert.equal(actual.binary.toNumber(), moreFakeBinaryMusicData.toNumber());
        assert.equal(actual.bump, bump);
    });


});
