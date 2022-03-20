module Msg.Anchor exposing (FromAnchorMsg(..), ToAnchorMsg(..))

import Model.PublicKey exposing (PublicKey)


type ToAnchorMsg
    = InitProgram PublicKey
    | PurchasePrimary PublicKey
    | SubmitToEscrow PublicKey Float


type
    FromAnchorMsg
    -- state lookup attempt
    = SuccessOnStateLookup String
    | FailureOnStateLookup String
      -- init program attempt
    | FailureOnInitProgram String
      -- purchase primary attempt
    | FailureOnPurchasePrimary String
    -- submit to escrow attempt
    | FailureOnSubmitToEscrow String
