module Model.Ledger exposing (EscrowItem, Ledger, checkOwnership, decode, getEscrowItem)

import Json.Decode as Decode
import Model.Lamports exposing (Lamports)
import Model.Wallet exposing (Wallet)



-- Success


type alias Ledger =
    { price : Lamports
    , resale : Float
    , originalSupplyRemaining : Int
    , owners : List Wallet
    , escrow : List EscrowItem

    -- not actually in the ledger
    -- just the current user
    , wallet : Wallet
    }


type alias EscrowItem =
    { price : Lamports
    , seller : Wallet
    }


decode : String -> Result Decode.Error Ledger
decode string =
    let
        escrowItemDecoder : Decode.Decoder EscrowItem
        escrowItemDecoder =
            Decode.map2 EscrowItem
                (Decode.field "price" Decode.int)
                (Decode.field "seller" Decode.string)

        decoder : Decode.Decoder Ledger
        decoder =
            Decode.map6 Ledger
                (Decode.field "price" Decode.int)
                (Decode.field "resale" Decode.float)
                (Decode.field "originalSupplyRemaining" Decode.int)
                (Decode.field "owners" (Decode.list Decode.string))
                (Decode.field "escrow" (Decode.list escrowItemDecoder))
                (Decode.field "wallet" Decode.string)
    in
    Decode.decodeString decoder string


checkOwnership : Ledger -> Bool
checkOwnership ledger =
    List.member
        ledger.wallet
        ledger.owners


getEscrowItem : Ledger -> Maybe EscrowItem
getEscrowItem ledger =
    let
        filter =
            List.filter
                (\ei -> ei.seller == ledger.wallet)
                ledger.escrow
    in
    case filter of
        [] ->
            Nothing

        head :: _ ->
            Just head
