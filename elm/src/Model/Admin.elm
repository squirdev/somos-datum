module Model.Admin exposing (Admin(..), getWallet)

import Model.Wallet exposing (Wallet)


type Admin
    = WaitingForWallet
    | HasWallet Wallet


getWallet : Admin -> Maybe Wallet
getWallet admin =
    case admin of
        WaitingForWallet ->
            Nothing

        HasWallet wallet ->
            Just wallet
