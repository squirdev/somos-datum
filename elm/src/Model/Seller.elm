module Model.Seller exposing (Seller(..), getWallet)

import Model.Ledger exposing (Ledger, Ledgers)
import Model.Release exposing (Release)
import Model.Wallet exposing (Wallet)


type Seller
    = WaitingForWallet
    | WaitingForStateLookup Wallet
    | Console Ledgers
    | Typing Release String Ledgers
    | PriceNotValidFloat Release Ledgers


getWallet : Seller -> Maybe Wallet
getWallet seller =
    case seller of
        WaitingForWallet ->
            Nothing

        WaitingForStateLookup wallet ->
            Just wallet

        Console ledgers ->
            Just ledgers.wallet

        Typing _ _ ledgers ->
            Just ledgers.wallet

        PriceNotValidFloat _ ledgers ->
            Just ledgers.wallet
