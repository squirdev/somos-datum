module Msg.Phantom exposing (FromPhantomMsg(..), ToPhantomMsg(..))

type FromPhantomMsg
    -- connection attempt
    = SuccessOnConnection
    | ErrorOnConnection String

type ToPhantomMsg
    -- connection attempt
    = Connect
