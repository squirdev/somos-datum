port module Sub.Phantom exposing (connectFailureListener, connectSender, connectSuccessListener)

-- senders


port connectSender : () -> Cmd msg



-- listeners


port connectSuccessListener : (String -> msg) -> Sub msg


port connectFailureListener : (String -> msg) -> Sub msg
