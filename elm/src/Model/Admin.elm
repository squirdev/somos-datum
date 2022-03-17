module Model.Admin exposing (Admin(..), getPublicKey)

import Model.PublicKey exposing (PublicKey)


type Admin
    = WaitingForWallet
    | HasWallet PublicKey


getPublicKey : Admin -> Maybe PublicKey
getPublicKey admin =
    case admin of
        WaitingForWallet ->
            Nothing

        HasWallet publicKey ->
            Just publicKey
