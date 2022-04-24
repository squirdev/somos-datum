port module Sub.Anchor exposing (..)

-- senders


port initProgramSender : String -> Cmd msg


port getCurrentStateSender : String -> Cmd msg


port purchasePrimarySender : String -> Cmd msg


port submitToEscrowSender : String -> Cmd msg


port removeFromEscrowSender : String -> Cmd msg


port purchaseSecondarySender : String -> Cmd msg



-- listeners


port getCurrentStateSuccessListener : (String -> msg) -> Sub msg


port getCurrentStateFailureListener : (String -> msg) -> Sub msg


port initProgramFailureListener : (String -> msg) -> Sub msg


port purchasePrimaryFailureListener : (String -> msg) -> Sub msg


port submitToEscrowFailureListener : (String -> msg) -> Sub msg


port purchaseSecondaryFailureListener : (String -> msg) -> Sub msg


port genericErrorListener : (String -> msg) -> Sub msg
