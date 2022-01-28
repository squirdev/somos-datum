module Model.Anchor exposing (AnchorState, Anchor(..))

type Anchor
    = WaitingForWallet
    | JustHasWallet PublicKey
    | WaitingForProgramInit PublicKey
    | Ready AnchorState

type alias PublicKey = String

type alias AnchorState =
    { json: String
    }
