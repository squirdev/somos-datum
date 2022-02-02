module Msg.Phantom exposing (FromPhantomMsg(..), ToPhantomMsg(..))


type
    ToPhantomMsg
    -- connection attempt
    = Connect
      -- sign message attempt
    | SignMessage PublicKey


type
    FromPhantomMsg
    -- connection attempt
    = SuccessOnConnection PublicKey
    | ErrorOnConnection Error
      -- sign message attempt
    | SuccessOnSignMessage Json
    | FailureOnSignMessage Error


type alias PublicKey =
    String


type alias Json =
    String


type alias Error =
    String
