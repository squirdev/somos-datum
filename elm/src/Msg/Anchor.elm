module Msg.Anchor exposing (FromAnchorMsg(..), ToAnchorMsg(..))


type ToAnchorMsg
    = TODO


type
    FromAnchorMsg
    -- state lookup attempt
    = SuccessOnStateLookup String
    | FailureOnStateLookup String
