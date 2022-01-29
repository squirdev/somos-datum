module Model.Anchor exposing (Anchor(..), AnchorState, decode)

import Json.Decode as Decode


type Anchor
    = WaitingForWallet
    | JustHasWallet PublicKey
    | WaitingForProgramInit PublicKey
    | UserWithNoOwnership AnchorState


type alias PublicKey =
    String


type alias AnchorState =
    { originalSupplyRemaining : Int
    , purchased : List String
    , secondaryMarket : List String
    }


decode : String -> Result Decode.Error AnchorState
decode string =
    let
        decoder : Decode.Decoder AnchorState
        decoder =
            Decode.map3 AnchorState
                (Decode.field "originalSupplyRemaining" Decode.int)
                (Decode.field "purchased" (Decode.list Decode.string))
                (Decode.field "secondaryMarket" (Decode.list Decode.string))
    in
    Decode.decodeString decoder string
