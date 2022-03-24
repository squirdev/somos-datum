// get ledger state
export async function getCurrentState(program, ledger, userJson) {
    try {
        // fetch state
        const _state = await program.account.ledger.fetch(ledger);
        // decode user
        const user = JSON.parse(userJson);
        const more = JSON.parse(user.more);

        function simplifyEscrowItem(escrowItem) {
            return {
                seller: escrowItem.seller.toString(),
                price: Number(escrowItem.price)
            }
        }

        // simplify for codec
        function simplify() {
            // TODO; send pubkey to elm
            const _owners = _state.owners.map(_publicKey => _publicKey.toString());
            const _escrow = _state.escrow.map(escrowItem => simplifyEscrowItem(escrowItem));
            const _more = {
                price: Number(_state.price.toString()),
                resale: _state.resale, // not a BN type
                originalSupplyRemaining: Number(_state.originalSupplyRemaining.toString()),
                owners: _owners,
                escrow: _escrow,
                wallet: more.wallet
            };
            return {
                role: user.role,
                more: JSON.stringify(_more)
            }
        }

        const state = simplify();
        // encode
        const simplified = JSON.stringify(state);
        // send state to elm
        app.ports.getCurrentStateSuccessListener.send(simplified);
        // log success
        console.log("program state retrieved & sent to elm");
        return state
    } catch (error) {
        // log error
        console.log("could not get program state: ", error);
        // build elm error
        const _error = {
            error: error.message,
            user: userJson
        }
        const _jsonError = JSON.stringify(_error)
        // send error to elm
        app.ports.getCurrentStateFailureListener.send(_jsonError)
    }
}
