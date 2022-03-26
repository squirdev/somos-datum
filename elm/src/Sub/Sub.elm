module Sub.Sub exposing (subs)

import Msg.Anchor exposing (FromAnchorMsg(..))
import Msg.Msg exposing (Msg(..))
import Msg.Phantom exposing (FromPhantomMsg(..))
import Sub.Anchor exposing (..)
import Sub.Phantom exposing (..)


subs : Sub Msg
subs =
    Sub.batch
        [ -- phantom connect
          connectFailureListener
            (\error ->
                FromPhantom (ErrorOnConnection error)
            )
        , getCurrentStateListener
            (\pubKey ->
                FromPhantom (GetCurrentState pubKey)
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
