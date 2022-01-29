module Msg.Anchor exposing (FromAnchorMsg(..), ToAnchorMsg(..))


type ToAnchorMsg
    = PurchasePrimary String


type
    FromAnchorMsg
    -- state lookup attempt
    = SuccessOnStateLookup String
    | FailureOnStateLookup String
      -- purchase primary attempt
    | FailureOnPurchasePrimary String
      -- download request
    | DownloadRequest String
