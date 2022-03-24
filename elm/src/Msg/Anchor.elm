module Msg.Anchor exposing (FromAnchorMsg(..), ToAnchorMsg(..))

import Model.Ledger exposing (EscrowItem, Ledger)
import Model.Wallet exposing (Wallet)


type ToAnchorMsg
    = InitProgram Wallet
    | PurchasePrimary Wallet
    | SubmitToEscrow Ledger Price
    | PurchaseSecondary EscrowItem Wallet


type alias Price =
    String


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
      -- purchase secondary attempt
    | FailureOnPurchaseSecondary String
