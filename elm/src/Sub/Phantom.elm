port module Sub.Phantom exposing (..)

-- senders


port connectSender : String -> Cmd msg


port signMessageSender : String -> Cmd msg


port openDownloadUrlSender : String -> Cmd msg



-- listeners
-- TODO: move to root


port getCurrentStateListener : (String -> msg) -> Sub msg


port connectFailureListener : (String -> msg) -> Sub msg


port signMessageSuccessListener : (String -> msg) -> Sub msg


port signMessageFailureListener : (String -> msg) -> Sub msg
