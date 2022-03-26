// get ledger state
export async function getLedger(program, ledger) {
    try {
        // fetch state
        const _state = await program.account.ledger.fetch(ledger);

        // simplify for codec
        function simplifyEscrowItem(escrowItem) {
            return {
                seller: escrowItem.seller.toString(),
                price: Number(escrowItem.price)
            }
        }

        function simplify() {
            const _owners = _state.owners.map(_publicKey => _publicKey.toString());
            const _escrow = _state.escrow.map(escrowItem => simplifyEscrowItem(escrowItem));
            return {
                price: Number(_state.price.toString()),
                resale: _state.resale, // not a BN type
                originalSupplyRemaining: Number(_state.originalSupplyRemaining.toString()),
                owners: _owners,
                escrow: _escrow
            };
        }

        return simplify();
    } catch (error) {
        // log error
        console.log(error.toString());
        // send error to elm
        app.ports.getCurrentStateFailureListener.send(error.message)
    }
}

// send ledgers to elm
export async function sendLedgers(userJson, ledgerOne) {
    try {
        // decode user
        const user = JSON.parse(userJson);
        const more = JSON.parse(user.more);
        const ledgers = {
            one: ledgerOne,
            wallet: more.wallet
        }
        const response = {
            role: user.role,
            more: JSON.stringify(ledgers)
        }
        // send state to elm
        app.ports.getCurrentStateSuccessListener.send(JSON.stringify(response));
        // log success
        console.log("ledgers packaged & sent to elm");
    } catch (error) {
        // log error
        console.log(error.toString());
        // send error to elm
        app.ports.getCurrentStateFailureListener.send(error.message)
    }
}
