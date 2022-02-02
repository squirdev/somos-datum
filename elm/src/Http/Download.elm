module Http.Download exposing (post)

import Http
import Http.Response exposing (responseDecoder)
import Json.Encode as Encode
import Model.Phantom exposing (PhantomSignature)
import Msg.Msg exposing (Msg(..))


post : PhantomSignature -> Cmd Msg
post request =
    Http.post
        { url = "https://u849eb767a.execute-api.us-west-2.amazonaws.com/default/resource"
        , body = Http.jsonBody (requestEncoder request)
        , expect = Http.expectJson AwsPreSign responseDecoder
        }


requestEncoder : PhantomSignature -> Encode.Value
requestEncoder phantomSignature =
    Encode.object
        [ ( "message", Encode.string phantomSignature.message )
        , ( "signature", Encode.string phantomSignature.signature )
        , ( "user", Encode.string phantomSignature.user )
        , ( "userDecoded", Encode.string phantomSignature.userDecoded )
        ]
