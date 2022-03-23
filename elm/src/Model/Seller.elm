module Model.Seller exposing (Seller(..), getWallet, Selling(..), Ownership(..))

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
    | PriceDecided String Ledger
    | PriceIsValidFloat Float Ledger
    | PriceNotValidFloat Ledger
    | Done Ledger



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


                        PriceDecided _ ledger ->
                            Just ledger.wallet


                        PriceIsValidFloat _ ledger ->
                            Just ledger.wallet


                        PriceNotValidFloat ledger ->
                            Just ledger.wallet


                        Done ledger ->
                            Just ledger.wallet



        WithoutOwnership ledger ->
            Just ledger.wallet

