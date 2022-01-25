module Sub.Sub exposing (subs)

import Msg.Msg exposing (Msg(..))
import Msg.Phantom exposing (FromPhantomMsg(..))
import Sub.Phantom exposing (connectFailureListener, connectSuccessListener)


subs : Sub Msg
subs =
    Sub.batch
        [ connectSuccessListener (\pubKey -> FromPhantom (SuccessOnConnection pubKey))
        , connectFailureListener (\error -> FromPhantom (ErrorOnConnection error))
        ]
