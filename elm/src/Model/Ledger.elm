module Model.Ledger exposing (Ledger, LedgerLookupFailure, decodeFailure, decodeSuccess, isAccountDoesNotExistError)

import Json.Decode as Decode
import Model.Lamports exposing (Lamports)
import Model.PublicKey exposing (PublicKey)



-- Success


type alias Ledger =
    { price : Lamports
    , resale : Float
    , originalSupplyRemaining : Int
    , owners : List PublicKey

    -- not actually in the ledger
    -- just the current user
    , user : PublicKey
    }


decodeSuccess : String -> Result Decode.Error Ledger
decodeSuccess string =
    let
        decoder : Decode.Decoder Ledger
        decoder =
            Decode.map5 Ledger
                (Decode.field "price" Decode.int)
                (Decode.field "resale" Decode.float)
                (Decode.field "originalSupplyRemaining" Decode.int)
                (Decode.field "owners" (Decode.list Decode.string))
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
