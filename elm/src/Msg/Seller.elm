module Msg.Seller exposing (FromSellerMsg(..))

import Model.Ledger exposing (Ledger)


type FromSellerMsg
    = Typing String Ledger
