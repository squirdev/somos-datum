module Model.Ledger exposing (EscrowItem, Ledger, Ledgers, checkOwnership, decode, getEscrowItem, getMinEscrowItem, toList)

import Json.Decode as Decode
import Model.Lamports exposing (Lamports)
import Model.Release as Release exposing (Release)
import Model.Wallet exposing (Wallet)



-- Success


type alias Ledger =
    { price : Lamports
    , resale : Float
    , originalSupply : Int
    , originalSupplyRemaining : Int
    , owners : List Wallet
    , escrow : List EscrowItem

    -- not actually in the ledger
    -- just the release index
    , release : Release
    }


type alias EscrowItem =
    { price : Lamports
    , seller : Wallet
    }


type alias Ledgers =
    { one : Ledger

    -- , two : Ledger
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

        releaseDecoder : Decode.Decoder Release
        releaseDecoder =
            Decode.map Release.fromInt Decode.int

        ledgerDecoder : Decode.Decoder Ledger
        ledgerDecoder =
            Decode.map7 Ledger
                (Decode.field "price" Decode.int)
                (Decode.field "resale" Decode.float)
                (Decode.field "originalSupply" Decode.int)
                (Decode.field "originalSupplyRemaining" Decode.int)
                (Decode.field "owners" (Decode.list Decode.string))
                (Decode.field "escrow" (Decode.list escrowItemDecoder))
                (Decode.field "release" releaseDecoder)

        decoder : Decode.Decoder Ledgers
        decoder =
            Decode.map2 Ledgers
                (Decode.field "one" ledgerDecoder)
                -- (Decode.field "two" ledgerDecoder)
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
