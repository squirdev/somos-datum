module Model.Phantom exposing (Phantom(..), PubKey, init)


type Phantom
    = Connected PubKey
    | NotConnected


type alias PubKey =
    { pubKey : String
    }


init : Phantom
init =
    NotConnected
