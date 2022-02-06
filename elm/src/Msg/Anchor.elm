module Msg.Anchor exposing (FromAnchorMsg(..), ToAnchorMsg(..))


import Model.PublicKey exposing (PublicKey)

type ToAnchorMsg
    = InitProgram PublicKey
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
