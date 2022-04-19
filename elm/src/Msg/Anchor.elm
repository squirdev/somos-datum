module Msg.Anchor exposing (FromAnchorMsg(..), ToAnchorMsg(..))

import Model.Ledger exposing (EscrowItem, Ledgers)
import Model.Release exposing (Release)
import Model.Role exposing (Role)
import Model.Wallet exposing (Wallet)


type ToAnchorMsg
    = InitProgram Wallet Release
    | PurchasePrimary Wallet Wallet Role Release
    | SubmitToEscrow Price Ledgers Release
    | PurchaseSecondary EscrowItem Wallet Release


type alias Price =
    String


type
    FromAnchorMsg
    -- TODO; clean up failures in favor of generic
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
