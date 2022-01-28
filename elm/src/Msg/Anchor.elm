module Msg.Anchor exposing (ToAnchorMsg(..), FromAnchorMsg(..))

type ToAnchorMsg
    = TODO

type FromAnchorMsg
    -- state lookup attempt
    = SuccessOnStateLookup String
    | FailureOnStateLookup String
