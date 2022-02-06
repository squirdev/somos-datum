module Model.Anchor.Anchor exposing (Anchor(..), getPublicKey)

import Model.Anchor.AnchorState exposing (AnchorState)
import Model.Anchor.DownloadStatus as DownloadStatus
import Model.Anchor.Ownership exposing (Ownership(..))


type Anchor
    = WaitingForWallet
    | JustHasWallet PublicKey
    | WaitingForProgramInit PublicKey
    | UserWithNoOwnership AnchorState
    | UserWithOwnership Ownership


type alias PublicKey =
    String


getPublicKey : Anchor -> Maybe PublicKey
getPublicKey anchor =
    case anchor of
        WaitingForWallet ->
            Nothing

        JustHasWallet publicKey ->
            Just publicKey

        WaitingForProgramInit publicKey ->
            Just publicKey

        UserWithNoOwnership anchorState ->
            Just anchorState.user

        UserWithOwnership ownership ->
            case ownership of
                Console anchorState _ ->
                    Just anchorState.user

                Download downloadStatus ->
                    case downloadStatus of
                        DownloadStatus.InvokedAndWaiting phantomSignature ->
                            Just phantomSignature.userDecoded

                        DownloadStatus.Done response ->
                            Just response.user
