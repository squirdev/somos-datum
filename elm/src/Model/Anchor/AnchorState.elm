module Model.Anchor.AnchorState exposing (AnchorState, AnchorStateLookupFailure, decodeFailure, decodeSuccess, isAccountDoesNotExistError)

import Json.Decode as Decode



-- Success


type alias PublicKey =
    String


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
