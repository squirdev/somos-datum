module Msg.Phantom exposing (FromPhantomMsg(..), ToPhantomMsg(..))

import Model.Role exposing (Role)
import Model.Wallet exposing (Wallet)


type
    ToPhantomMsg
    -- connection attempt
    = Connect Role
      -- sign message attempt
    | SignMessage Wallet


type
    FromPhantomMsg
    -- connection attempt
    = SuccessOnConnection Json
    | ErrorOnConnection Error
      -- sign message attempt
    | SuccessOnSignMessage Json
    | FailureOnSignMessage Error


type alias Json =
    String


type alias Error =
    String
