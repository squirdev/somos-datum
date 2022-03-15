module Model.Buyer exposing (Buyer(..), getPublicKey)

import Model.DownloadStatus as DownloadStatus
import Model.Ledger exposing (Ledger)
import Model.Ownership exposing (Ownership(..))
import Model.PublicKey exposing (PublicKey)


type Buyer
    = WaitingForWallet
    | WaitingForStateLookup PublicKey
    | NeedsToInitProgram PublicKey
    | WithoutOwnership Ledger
    | WithOwnership Ownership


getPublicKey : Buyer -> Maybe PublicKey
getPublicKey anchor =
    case anchor of
        WaitingForWallet ->
            Nothing

        WaitingForStateLookup publicKey ->
            Just publicKey

        NeedsToInitProgram publicKey ->
            Just publicKey

        WithoutOwnership anchorState ->
            Just anchorState.user

        WithOwnership ownership ->
            case ownership of
                Console anchorState _ ->
                    Just anchorState.user

                Download downloadStatus ->
                    case downloadStatus of
                        DownloadStatus.InvokedAndWaiting phantomSignature ->
                            Just phantomSignature.userDecoded

                        DownloadStatus.Done response ->
                            Just response.user
