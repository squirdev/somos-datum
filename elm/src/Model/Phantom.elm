module Model.Phantom exposing (PhantomSignature, decodeSignature)

import Json.Decode as Decode


type alias PhantomSignature =
    { message : String
    , signature : String
    , user : String
    , userDecoded : String
    }


decodeSignature : String -> Result Decode.Error PhantomSignature
decodeSignature string =
    let
        decoder : Decode.Decoder PhantomSignature
        decoder =
            Decode.map4 PhantomSignature
                (Decode.field "message" Decode.string)
                (Decode.field "signature" Decode.string)
                (Decode.field "user" Decode.string)
                (Decode.field "userDecoded" Decode.string)
    in
    Decode.decodeString decoder string
