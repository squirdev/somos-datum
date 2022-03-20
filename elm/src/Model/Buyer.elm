module Model.Buyer exposing (Buyer(..), getWallet)

import Model.DownloadStatus as DownloadStatus
import Model.Ledger exposing (Ledger)
import Model.Ownership exposing (Ownership(..))
import Model.Wallet exposing (Wallet)


type Buyer
    = WaitingForWallet
    | WaitingForStateLookup Wallet
    | WithoutOwnership Ledger
    | WithOwnership Ownership


getWallet : Buyer -> Maybe Wallet
getWallet anchor =
    case anchor of
        WaitingForWallet ->
            Nothing

        WaitingForStateLookup wallet ->
            Just wallet

        WithoutOwnership ledger ->
            Just ledger.wallet

        WithOwnership ownership ->
            case ownership of
                Console ledger ->
                    Just ledger.wallet

                Download downloadStatus ->
                    case downloadStatus of
                        DownloadStatus.InvokedAndWaiting phantomSignature ->
                            Just phantomSignature.userDecoded

                        DownloadStatus.Done response ->
                            Just response.user
