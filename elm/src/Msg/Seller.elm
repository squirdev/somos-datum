module Msg.Seller exposing (FromSellerMsg(..))

import Model.Ledger exposing (Ledgers)
import Model.Release exposing (Release)


type FromSellerMsg
    = Typing Release String Ledgers
