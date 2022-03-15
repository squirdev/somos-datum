module Model.Anchor.Seller exposing (Seller(..), getPublicKey)

import Model.PublicKey exposing (PublicKey)

type Seller
    = WaitingForWallet
    | WaitingForStateLookup PublicKey
    | NeedsToInitProgram PublicKey
    | WithoutOwnership PublicKey


getPublicKey : Seller -> Maybe PublicKey
getPublicKey seller =
    case seller of
        WaitingForWallet ->
            Nothing

        WaitingForStateLookup publicKey ->
            Just publicKey

        NeedsToInitProgram publicKey ->
            Just publicKey

        WithoutOwnership publicKey ->
             Just publicKey
