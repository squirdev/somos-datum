port module Sub.Phantom exposing (connectFailureListener, connectSender, connectSuccessListener, openDownloadUrlSender, signMessageFailureListener, signMessageSender, signMessageSuccessListener)

-- senders


port connectSender : String -> Cmd msg


port signMessageSender : String -> Cmd msg


port openDownloadUrlSender : String -> Cmd msg



-- listeners


port connectSuccessListener : (String -> msg) -> Sub msg


port connectFailureListener : (String -> msg) -> Sub msg


port signMessageSuccessListener : (String -> msg) -> Sub msg


port signMessageFailureListener : (String -> msg) -> Sub msg
