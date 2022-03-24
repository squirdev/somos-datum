module Model.Ledger exposing (Ledger, checkForSale, checkOwnership, decode)

import Json.Decode as Decode
import Model.Lamports exposing (Lamports)
import Model.Wallet exposing (Wallet)



-- Success


type alias Ledger =
    { price : Lamports
    , resale : Float
    , originalSupplyRemaining : Int
    , owners : List Wallet
    , escrow : List Wallet

    -- not actually in the ledger
    -- just the current user
    , wallet : Wallet
    }


decode : String -> Result Decode.Error Ledger
decode string =
    let
        decoder : Decode.Decoder Ledger
        decoder =
            Decode.map6 Ledger
                (Decode.field "price" Decode.int)
                (Decode.field "resale" Decode.float)
                (Decode.field "originalSupplyRemaining" Decode.int)
                (Decode.field "owners" (Decode.list Decode.string))
                (Decode.field "escrow" (Decode.list Decode.string))
                (Decode.field "wallet" Decode.string)
    in
    Decode.decodeString decoder string


checkOwnership : Ledger -> Bool
checkOwnership ledger =
    List.member
        ledger.wallet
        ledger.owners


checkForSale : Ledger -> Bool
checkForSale ledger =
    List.member
        ledger.wallet
        ledger.escrow
