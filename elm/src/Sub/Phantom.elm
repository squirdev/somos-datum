port module Sub.Phantom exposing (connectFailureListener, connectSender, connectSuccessListener, signMessageFailureListener, signMessageSender, signMessageSuccessListener)

-- senders


port connectSender : () -> Cmd msg


port signMessageSender : String -> Cmd msg



-- listeners


port connectSuccessListener : (String -> msg) -> Sub msg


port connectFailureListener : (String -> msg) -> Sub msg


port signMessageSuccessListener : (String -> msg) -> Sub msg


port signMessageFailureListener : (String -> msg) -> Sub msg
