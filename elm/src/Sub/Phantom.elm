port module Sub.Phantom exposing (connectSender, connectSuccessListener, connectFailureListener)

-- senders
port connectSender: () -> Cmd msg


-- listeners
port connectSuccessListener: (Bool -> msg) -> Sub msg

port connectFailureListener: (String -> msg) -> Sub msg
