module Model.Seller exposing (Seller(..), getPublicKey)

import Model.Ledger exposing (Ledger)
import Model.PublicKey exposing (PublicKey)


type Seller
    = WaitingForWallet
    | WaitingForStateLookup PublicKey
    | WithOwnership Ledger
    | WithoutOwnership Ledger


getPublicKey : Seller -> Maybe PublicKey
getPublicKey seller =
    case seller of
        WaitingForWallet ->
            Nothing

        WaitingForStateLookup publicKey ->
            Just publicKey

        WithOwnership ledger ->
            Just ledger.user

        WithoutOwnership ledger ->
            Just ledger.user
