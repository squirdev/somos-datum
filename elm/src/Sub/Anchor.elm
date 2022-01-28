port module Sub.Anchor exposing (getCurrentStateFailureListener, getCurrentStateSuccessListener, isConnectedSender)

-- senders


port isConnectedSender : () -> Cmd msg



-- listeners


port getCurrentStateSuccessListener : (String -> msg) -> Sub msg


port getCurrentStateFailureListener : (String -> msg) -> Sub msg
