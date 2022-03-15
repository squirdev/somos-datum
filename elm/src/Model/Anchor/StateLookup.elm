module Model.Anchor.StateLookup exposing (StateLookup, decode, Indicated(..))

import Json.Decode as Decode

type alias StateLookup =
    { indicator : String -- buy or sell indicator
    , more : String -- more json
    }

type Indicated
    = Buy String
    | Sell String

decode : String -> Result String Indicated
decode string =
    let
        decoder : Decode.Decoder StateLookup
        decoder =
            Decode.map2 StateLookup
                (Decode.field "indicator" Decode.string)
                (Decode.field "more" Decode.string)
    in
    case Decode.decodeString decoder string of
        Ok value ->
            case value.indicator of
                "buy" ->
                    Ok (Buy value.more)

                "sell" ->
                    Ok (Sell value.more)

                _ ->
                    Err "invalid indicator"

        Err error ->
            Err (Decode.errorToString error)
