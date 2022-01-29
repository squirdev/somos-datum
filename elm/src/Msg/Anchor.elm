module Msg.Anchor exposing (FromAnchorMsg(..), ToAnchorMsg(..))


type ToAnchorMsg
    = InitProgram PublicKey
    | PurchasePrimary PublicKey


type alias PublicKey =
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
      -- download request
    | DownloadRequest String
