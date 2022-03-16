module Msg.Anchor exposing (FromAnchorMsg(..), ToAnchorMsg(..))

import Model.PublicKey exposing (PublicKey)
import Model.User as User exposing (User)


type ToAnchorMsg
    = InitProgram User.WithContext
    | PurchasePrimary PublicKey


type
    FromAnchorMsg
    -- state lookup attempt
    = SuccessOnStateLookup String
    | FailureOnStateLookup String
      -- init program attempt
    | FailureOnInitProgram String
      -- purchase primary attempt
    | FailureOnPurchasePrimary String
