module Model.Anchor exposing (Anchor(..), AnchorState)


type Anchor
    = WaitingForWallet
    | JustHasWallet PublicKey
    | WaitingForProgramInit PublicKey
    | Ready AnchorState


type alias PublicKey =
    String


type alias AnchorState =
    { json : String
    }
