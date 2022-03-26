module Msg.Seller exposing (FromSellerMsg(..))

import Model.Ledger exposing (Ledgers)


type FromSellerMsg
    = Typing String Ledgers
