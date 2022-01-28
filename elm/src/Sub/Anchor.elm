port module Sub.Anchor exposing (downloadRequestListener, getCurrentStateFailureListener, getCurrentStateSuccessListener, isConnectedSender, purchasePrimaryFailureListener, purchasePrimarySender)

-- senders


port isConnectedSender : () -> Cmd msg


port purchasePrimarySender : () -> Cmd msg



-- listeners


port getCurrentStateSuccessListener : (String -> msg) -> Sub msg


port getCurrentStateFailureListener : (String -> msg) -> Sub msg


port downloadRequestListener : (String -> msg) -> Sub msg


port purchasePrimaryFailureListener : (String -> msg) -> Sub msg
