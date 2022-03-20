module Model.Seller exposing (Seller(..), getWallet)

import Model.Ledger exposing (Ledger)
import Model.Wallet exposing (Wallet)


type Seller
    = WaitingForWallet
    | WaitingForStateLookup Wallet
    | WithOwnership Ledger
    | WithoutOwnership Ledger


getWallet : Seller -> Maybe Wallet
getWallet seller =
    case seller of
        WaitingForWallet ->
            Nothing

        WaitingForStateLookup wallet ->
            Just wallet

        WithOwnership ledger ->
            Just ledger.wallet

        WithoutOwnership ledger ->
            Just ledger.wallet
