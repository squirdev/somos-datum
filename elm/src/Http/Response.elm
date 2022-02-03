module Http.Response exposing (Response, responseDecoder)

import Json.Decode as Decode


type alias Response =
    { user : String
    , url : String
    }


responseDecoder : Decode.Decoder Response
responseDecoder =
    Decode.map2 Response
        (Decode.field "user" Decode.string)
        (Decode.field "url" Decode.string)
