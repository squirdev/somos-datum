module Model.Anchor exposing (Anchor(..), AnchorState)


type Anchor
    = WaitingForWallet
    | JustHasWallet PublicKey
    | WaitingForProgramInit PublicKey
    | UserWithNoOwnership AnchorState


type alias PublicKey =
    String


type alias AnchorState =
    { json : String
    }
