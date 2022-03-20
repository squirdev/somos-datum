module Msg.Anchor exposing (FromAnchorMsg(..), ToAnchorMsg(..))

import Model.Wallet exposing (Wallet)


type ToAnchorMsg
    = InitProgram Wallet
    | PurchasePrimary Wallet
    | SubmitToEscrow Wallet Float


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
