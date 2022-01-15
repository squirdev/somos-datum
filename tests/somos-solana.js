const assert = require("assert");
const anchor = require("@project-serum/anchor");

describe("somos-solana", () => {
    // Configure the client
    const provider = anchor.Provider.env();
    anchor.setProvider(provider);
    // fetch program
    const program = anchor.workspace.SomosSolana;
    // derive pda key with bump
    let pdaPublicKey, bump;
    before(async () => {
        [pdaPublicKey, bump] =
            await anchor.web3.PublicKey.findProgramAddress(
                [Buffer.from("somos_seed")],
                program.programId
            );
    });
    // data
    let title = "EP01";
    let song01 = {
        title: "Track01",
        encodedWav: "base64_str_01"
    };
    // init
    it("initializes music account with data & bump", async () => {
        await program.rpc.initialize(new anchor.BN(bump), title, song01, song01, {
            accounts: {
                user: provider.wallet.publicKey,
                musicAccount: pdaPublicKey,
                systemProgram: anchor.web3.SystemProgram.programId,
            }
        });
        let actual = await program.account.project.fetch(
            pdaPublicKey
        );
        console.log(actual)
        assert.equal(actual.title.toString(), title.toNumber());
        assert.equal(actual.bump, bump);
    });

    // data
    let newTitle = "EP_01"
    // update
    it("updates music account with new binary data", async () => {
        await program.rpc.update(newTitle, {
            accounts: {
                musicAccount: pdaPublicKey
            }
        })
        let actual = await program.account.project.fetch(
            pdaPublicKey
        )
        console.log(actual)
        assert.equal(actual.title.toString(), newTitle.toString());
        assert.equal(actual.bump, bump);
    });

});
