module Http.Response exposing (Response, responseDecoder)

import Json.Decode as Decode


type alias Response =
    { verified : Bool
    , user : String
    }


responseDecoder : Decode.Decoder Response
responseDecoder =
    Decode.map2 Response
        (Decode.field "verified" Decode.bool)
        (Decode.field "user" Decode.string)
