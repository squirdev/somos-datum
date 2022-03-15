module Msg.Phantom exposing (FromPhantomMsg(..), ToPhantomMsg(..))

import Model.PublicKey exposing (PublicKey)
import Model.User exposing (User)


type
    ToPhantomMsg
    -- connection attempt
    = Connect User
      -- sign message attempt
    | SignMessage PublicKey


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
