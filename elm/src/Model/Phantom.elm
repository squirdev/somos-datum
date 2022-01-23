module Model.Phantom exposing (Phantom, init)

type alias Phantom =
    { isConnected: Bool
    }

init : Phantom
init =
     { isConnected = False
     }
