module Sub.Sub exposing (subs)

import Msg.Anchor exposing (FromAnchorMsg(..))
import Msg.Msg exposing (Msg(..))
import Msg.Phantom exposing (FromPhantomMsg(..))
import Sub.Anchor exposing (getCurrentStateFailureListener, getCurrentStateSuccessListener, initProgramFailureListener, purchasePrimaryFailureListener, submitToEscrowFailureListener)
import Sub.Phantom exposing (connectFailureListener, connectSuccessListener, signMessageFailureListener, signMessageSuccessListener)


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

        -- anchor init program
        , initProgramFailureListener
            (\error ->
                FromAnchor (FailureOnInitProgram error)
            )

        -- anchor purchase primary
        , purchasePrimaryFailureListener
            (\error ->
                FromAnchor (FailureOnPurchasePrimary error)
            )

        -- anchor submit to escrow
        , submitToEscrowFailureListener
            (\error ->
                FromAnchor (FailureOnSubmitToEscrow error)
            )

        -- phantom sign message
        , signMessageSuccessListener
            (\jsonString ->
                FromPhantom (SuccessOnSignMessage jsonString)
            )
        , signMessageFailureListener
            (\error ->
                FromPhantom (FailureOnSignMessage error)
            )
        ]
