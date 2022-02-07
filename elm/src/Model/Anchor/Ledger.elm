module Model.Anchor.Ledger exposing (Ledger, LedgerLookupFailure, decodeFailure, decodeSuccess, isAccountDoesNotExistError)

import Json.Decode as Decode
import Model.PublicKey exposing (PublicKey)



-- Success
-- TODO: decode price


type alias Ledger =
    { originalSupplyRemaining : Int
    , purchased : List PublicKey
    , secondaryMarket : List PublicKey
    , user : PublicKey
    }


decodeSuccess : String -> Result Decode.Error Ledger
decodeSuccess string =
    let
        decoder : Decode.Decoder Ledger
        decoder =
            Decode.map4 Ledger
                (Decode.field "originalSupplyRemaining" Decode.int)
                (Decode.field "purchased" (Decode.list Decode.string))
                (Decode.field "secondaryMarket" (Decode.list Decode.string))
                (Decode.field "user" Decode.string)
    in
    Decode.decodeString decoder string



-- Failure


type alias LedgerLookupFailure =
    { error : String
    , user : String
    }


decodeFailure : String -> Result Decode.Error LedgerLookupFailure
decodeFailure string =
    let
        decoder =
            Decode.map2 LedgerLookupFailure
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
