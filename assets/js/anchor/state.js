// get ledger state
export async function getCurrentState(program, release01PubKey, user) {
    try {
        // fetch state
        const _state = await program.account.ledger.fetch(release01PubKey);
        // simplify for codec
        function simplify() {
            // TODO; send pubkey to elm
            const _owners = _state.owners.map(_publicKey => _publicKey.toString());
            return {
                price: Number(_state.price.toString()),
                resale: _state.resale, // not a BN type
                originalSupplyRemaining: Number(_state.originalSupplyRemaining.toString()),
                owners: _owners,
                user: user
            }
        }
        const state = simplify()
        // encode
        const simplified = JSON.stringify(state)
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
