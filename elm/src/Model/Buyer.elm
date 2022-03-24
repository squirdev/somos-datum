module Model.Buyer exposing (Buyer(..), getWallet)

import Model.DownloadStatus as DownloadStatus exposing (DownloadStatus)
import Model.Ledger exposing (Ledger)
import Model.Wallet exposing (Wallet)


type Buyer
    = WaitingForWallet
    | WaitingForStateLookup Wallet
    | Console Ledger
    | Download DownloadStatus


getWallet : Buyer -> Maybe Wallet
getWallet anchor =
    case anchor of
        WaitingForWallet ->
            Nothing

        WaitingForStateLookup wallet ->
            Just wallet

        Console ledger ->
            Just ledger.wallet

        Download downloadStatus ->
            case downloadStatus of
                DownloadStatus.InvokedAndWaiting phantomSignature ->
                    Just phantomSignature.userDecoded

                DownloadStatus.Done response ->
                    Just response.user
