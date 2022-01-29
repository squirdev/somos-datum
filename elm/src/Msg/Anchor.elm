module Msg.Anchor exposing (FromAnchorMsg(..), ToAnchorMsg(..))


type ToAnchorMsg
    = PurchasePrimary


type
    FromAnchorMsg
    -- state lookup attempt
    = SuccessOnStateLookup String
    | FailureOnStateLookup String
      -- purchase primary attempt
    | FailureOnPurchasePrimary String
      -- download request
    | DownloadRequest String
