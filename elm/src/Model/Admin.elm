module Model.Admin exposing (Admin(..), getWallet)

import Model.Ledger exposing (Ledger, Ledgers)
import Model.Release exposing (Release)
import Model.Wallet exposing (Wallet)


type Admin
    = WaitingForWallet
    | HasWallet Wallet
    | Typing Release String Wallet
    | ViewingLedger Ledgers


getWallet : Admin -> Maybe Wallet
getWallet admin =
    case admin of
        WaitingForWallet ->
            Nothing

        HasWallet wallet ->
            Just wallet

        Typing _ _ wallet ->
            Just wallet

        ViewingLedger ledgers ->
            Just ledgers.wallet
