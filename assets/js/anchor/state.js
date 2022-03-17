// get ledger state
export async function getCurrentState(program, ledger, userJson) {
    try {
        // fetch state
        const _state = await program.account.ledger.fetch(ledger);
        // decode user
        const user = JSON.parse(userJson);

        // simplify for codec
        function simplify() {
            // TODO; send pubkey to elm
            const _owners = _state.owners.map(_publicKey => _publicKey.toString());
            const more = {
                price: Number(_state.price.toString()),
                resale: _state.resale, // not a BN type
                originalSupplyRemaining: Number(_state.originalSupplyRemaining.toString()),
                owners: _owners,
                user: user.more
            };
            return {
                user: user.user,
                more: JSON.stringify(more)
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
            user: user
        }
        const _jsonError = JSON.stringify(_error)
        // send error to elm
        app.ports.getCurrentStateFailureListener.send(_jsonError)
    }
}
