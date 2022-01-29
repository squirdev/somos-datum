module Model.Anchor exposing (Anchor(..), AnchorState, decode)

import Json.Decode as Decode


type Anchor
    = WaitingForWallet
    | JustHasWallet PublicKey
    | WaitingForProgramInit PublicKey
    | UserWithNoOwnership AnchorState
    | UserWithOwnership AnchorState Int


type alias PublicKey =
    String


type alias AnchorState =
    { originalSupplyRemaining : Int
    , purchased : List PublicKey
    , secondaryMarket : List PublicKey
    , user : PublicKey
    }


decode : String -> Result Decode.Error AnchorState
decode string =
    let
        decoder : Decode.Decoder AnchorState
        decoder =
            Decode.map4 AnchorState
                (Decode.field "originalSupplyRemaining" Decode.int)
                (Decode.field "purchased" (Decode.list Decode.string))
                (Decode.field "secondaryMarket" (Decode.list Decode.string))
                (Decode.field "user" Decode.string)
    in
    Decode.decodeString decoder string
