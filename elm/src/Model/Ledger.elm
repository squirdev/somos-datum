module Model.Ledger exposing (EscrowItem, Ledger, Ledgers, checkOwnership, decode, getEscrowItem, getMinEscrowItem, toList)

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
    }


type alias EscrowItem =
    { price : Lamports
    , seller : Wallet
    }


type alias Ledgers =
    { one : Ledger

    -- not actually in the ledger
    -- just the current user
    , wallet : Wallet
    }


toList : Ledgers -> List Ledger
toList ledgers =
    [ ledgers.one
    ]


decode : String -> Result Decode.Error Ledgers
decode string =
    let
        escrowItemDecoder : Decode.Decoder EscrowItem
        escrowItemDecoder =
            Decode.map2 EscrowItem
                (Decode.field "price" Decode.int)
                (Decode.field "seller" Decode.string)

        ledgerDecoder : Decode.Decoder Ledger
        ledgerDecoder =
            Decode.map5 Ledger
                (Decode.field "price" Decode.int)
                (Decode.field "resale" Decode.float)
                (Decode.field "originalSupplyRemaining" Decode.int)
                (Decode.field "owners" (Decode.list Decode.string))
                (Decode.field "escrow" (Decode.list escrowItemDecoder))

        decoder : Decode.Decoder Ledgers
        decoder =
            Decode.map2 Ledgers
                (Decode.field "one" ledgerDecoder)
                (Decode.field "wallet" Decode.string)
    in
    Decode.decodeString decoder string


checkOwnership : Wallet -> Ledger -> Bool
checkOwnership wallet ledger =
    List.member
        wallet
        ledger.owners


getEscrowItem : Wallet -> Ledger -> Maybe EscrowItem
getEscrowItem wallet ledger =
    let
        filter =
            List.filter
                (\ei -> ei.seller == wallet)
                ledger.escrow
    in
    case filter of
        [] ->
            Nothing

        head :: _ ->
            Just head


getMinEscrowItem : Ledger -> Maybe EscrowItem
getMinEscrowItem ledger =
    List.head <| List.sortBy .price ledger.escrow
