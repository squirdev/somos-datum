module Model.Seller exposing (Ownership(..), Seller(..), Selling(..), getWallet)

import Model.Ledger exposing (Ledger)
import Model.Wallet exposing (Wallet)


type Seller
    = WaitingForWallet
    | WaitingForStateLookup Wallet
    | WithOwnership Ownership
    | WithoutOwnership Ledger


type Ownership
    = Console Ledger
    | Sell Selling


type Selling
    = Typing String Ledger
    | PriceNotValidFloat Ledger
    | Done Wallet


getWallet : Seller -> Maybe Wallet
getWallet seller =
    case seller of
        WaitingForWallet ->
            Nothing

        WaitingForStateLookup wallet ->
            Just wallet

        WithOwnership ownership ->
            case ownership of
                Console ledger ->
                    Just ledger.wallet

                Sell selling ->
                    case selling of
                        Typing _ ledger ->
                            Just ledger.wallet

                        PriceNotValidFloat ledger ->
                            Just ledger.wallet

                        Done wallet ->
                            Just wallet

        WithoutOwnership ledger ->
            Just ledger.wallet
