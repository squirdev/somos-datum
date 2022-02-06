module Model.Anchor exposing (Anchor(..), AnchorState, AnchorStateLookupFailure, decodeFailure, decodeSuccess, getPublicKey, isAccountDoesNotExistError)

import Http.Response as Download
import Json.Decode as Decode
import Model.Phantom exposing (PhantomSignature)


type Anchor
    = WaitingForWallet
    | JustHasWallet PublicKey
    | WaitingForProgramInit PublicKey
    | UserWithNoOwnership AnchorState
    | UserWithOwnershipBeforeDownload AnchorState Int
    | UserWithOwnershipWaitingForPreSign PhantomSignature
    | UserWithOwnershipWithDownloadUrl Download.Response


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

        UserWithOwnershipBeforeDownload anchorState _ ->
            Just anchorState.user

        UserWithOwnershipWaitingForPreSign phantomSignature ->
            Just phantomSignature.userDecoded

        UserWithOwnershipWithDownloadUrl response ->
            Just response.user



-- Success


type alias AnchorState =
    { originalSupplyRemaining : Int
    , purchased : List PublicKey
    , secondaryMarket : List PublicKey
    , user : PublicKey
    }


decodeSuccess : String -> Result Decode.Error AnchorState
decodeSuccess string =
    let
        decoder : Decode.Decoder AnchorState
        decoder =
            Decode.map4 AnchorState
                (Decode.field "originalSupplyRemaining" Decode.int)
                (Decode.field "purchased" (Decode.list Decode.string))
                (Decode.field "secondaryMarket" (Decode.list Decode.string))
                (Decode.field "user" Decode.string)
    in
    Decode.decodeString decoder string



-- Failure


type alias AnchorStateLookupFailure =
    { error : String
    , user : String
    }


decodeFailure : String -> Result Decode.Error AnchorStateLookupFailure
decodeFailure string =
    let
        decoder =
            Decode.map2 AnchorStateLookupFailure
                (Decode.field "error" Decode.string)
                (Decode.field "user" Decode.string)
    in
    Decode.decodeString decoder string


isAccountDoesNotExistError : String -> Bool
isAccountDoesNotExistError error =
    let
        dne : String
        dne =
            "account does not exist"
    in
    String.toLower error
        |> String.contains dne
