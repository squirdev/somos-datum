module Msg.Phantom exposing (FromPhantomMsg(..), ToPhantomMsg(..))


type
    FromPhantomMsg
    -- connection attempt
    = SuccessOnConnection String
    | ErrorOnConnection String


type
    ToPhantomMsg
    -- connection attempt
    = Connect
