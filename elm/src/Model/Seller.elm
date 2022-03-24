module Model.Seller exposing (Seller(..), getWallet)

import Model.Ledger exposing (Ledger)
import Model.Wallet exposing (Wallet)


type Seller
    = WaitingForWallet
    | WaitingForStateLookup Wallet
    | Console Ledger
    | Typing String Ledger
    | PriceNotValidFloat Ledger


getWallet : Seller -> Maybe Wallet
getWallet seller =
    case seller of
        WaitingForWallet ->
            Nothing

        WaitingForStateLookup wallet ->
            Just wallet

        Console ledger ->
            Just ledger.wallet

        Typing _ ledger ->
            Just ledger.wallet

        PriceNotValidFloat ledger ->
            Just ledger.wallet
