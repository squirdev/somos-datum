module Sub.Sub exposing (subs)

import Msg.Msg exposing (Msg(..))
import Msg.Phantom exposing (FromPhantomMsg(..))
import Sub.Phantom exposing (connectFailureListener, connectSuccessListener)


subs : Sub Msg
subs =
    Sub.batch
        [ connectSuccessListener (\_ -> (FromPhantom SuccessOnConnection))
        , connectFailureListener (\s -> (FromPhantom (ErrorOnConnection s)))
        ]
