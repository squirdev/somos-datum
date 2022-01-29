// get ledger state
export async function getCurrentState(program, statePublicKey, user) {
    try {
        // fetch state
        const state = await program.account.ledger.fetch(statePublicKey);
        // define how to simplify for codec
        function simplify() {
            const _purchased = state.purchased.map(_publicKey => _publicKey.toString());
            const _secondaryMarket = state.secondaryMarket.map(_publicKey => _publicKey.toString());
            const _state = {
                originalSupplyRemaining: state.originalSupplyRemaining,
                purchased: _purchased,
                secondaryMarket: _secondaryMarket,
                user: user
            }
            return JSON.stringify(_state)
        }
        // simplify
        const simplified = simplify(state)
        // send state to elm
        app.ports.getCurrentStateSuccessListener.send(simplified);
        // log success
        console.log("program state retrieved & sent to elm");
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
