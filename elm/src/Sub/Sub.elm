module Sub.Sub exposing (subs)

import Msg.Anchor exposing (FromAnchorMsg(..))
import Msg.Msg exposing (Msg(..))
import Msg.Phantom exposing (FromPhantomMsg(..))
import Sub.Anchor exposing (downloadRequestListener, getCurrentStateFailureListener, getCurrentStateSuccessListener, purchasePrimaryFailureListener)
import Sub.Phantom exposing (connectFailureListener, connectSuccessListener)


subs : Sub Msg
subs =
    Sub.batch
        -- phantom connect
        [ connectSuccessListener
            (\pubKey ->
                FromPhantom (SuccessOnConnection pubKey)
            )
        , connectFailureListener
            (\error ->
                FromPhantom (ErrorOnConnection error)
            )

        -- anchor get current state
        , getCurrentStateSuccessListener
            (\jsonString ->
                FromAnchor (SuccessOnStateLookup jsonString)
            )
        , getCurrentStateFailureListener
            (\error ->
                FromAnchor (FailureOnStateLookup error)
            )

        -- download request
        , downloadRequestListener
            (\jsonString ->
                FromAnchor (SuccessOnPurchasePrimary jsonString)
            )

        -- anchor purchase primary
        , purchasePrimaryFailureListener
            (\error ->
                FromAnchor (FailureOnPurchasePrimary error)
            )
        ]
