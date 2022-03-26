module Model.Seller exposing (Seller(..), getWallet)

import Model.Ledger exposing (Ledger, Ledgers)
import Model.Wallet exposing (Wallet)


type Seller
    = WaitingForWallet
    | WaitingForStateLookup Wallet
    | Console Ledgers
    | Typing String Ledgers
    | PriceNotValidFloat Ledgers


getWallet : Seller -> Maybe Wallet
getWallet seller =
    case seller of
        WaitingForWallet ->
            Nothing

        WaitingForStateLookup wallet ->
            Just wallet

        Console ledgers ->
            Just ledgers.wallet

        Typing _ ledgers ->
            Just ledgers.wallet

        PriceNotValidFloat ledgers ->
            Just ledgers.wallet
