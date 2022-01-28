module Sub.Sub exposing (subs)

import Msg.Anchor exposing (FromAnchorMsg(..))
import Msg.Msg exposing (Msg(..))
import Msg.Phantom exposing (FromPhantomMsg(..))
import Sub.Anchor exposing (getCurrentStateFailureListener, getCurrentStateSuccessListener)
import Sub.Phantom exposing (connectFailureListener, connectSuccessListener)


subs : Sub Msg
subs =
    Sub.batch
        [ connectSuccessListener
            (\pubKey ->
                FromPhantom (SuccessOnConnection pubKey)
            )
        , connectFailureListener
            (\error ->
                FromPhantom (ErrorOnConnection error)
            )
        , getCurrentStateSuccessListener
            (\jsonString ->
                FromAnchor (SuccessOnStateLookup jsonString)
            )
        , getCurrentStateFailureListener
            (\error ->
                FromAnchor (FailureOnStateLookup error)
            )
        ]
