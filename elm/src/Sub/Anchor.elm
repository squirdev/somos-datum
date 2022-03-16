port module Sub.Anchor exposing (getCurrentStateFailureListener, getCurrentStateSuccessListener, initProgramFailureListener, initProgramSender, getCurrentStateSender, purchasePrimaryFailureListener, purchasePrimarySender)

-- senders

port initProgramSender : String -> Cmd msg

port getCurrentStateSender : String -> Cmd msg

port purchasePrimarySender : String -> Cmd msg



-- listeners


port getCurrentStateSuccessListener : (String -> msg) -> Sub msg


port getCurrentStateFailureListener : (String -> msg) -> Sub msg


port initProgramFailureListener : (String -> msg) -> Sub msg


port purchasePrimaryFailureListener : (String -> msg) -> Sub msg
