port module Sub.Anchor exposing (isConnectedSender, getCurrentStateSuccessListener, getCurrentStateFailureListener)

-- senders


port isConnectedSender : () -> Cmd msg

-- listeners


port getCurrentStateSuccessListener : (String -> msg) -> Sub msg

port getCurrentStateFailureListener : (String -> msg) -> Sub msg
