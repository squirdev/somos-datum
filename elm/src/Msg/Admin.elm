module Msg.Admin exposing (FromAdminMsg(..))

import Model.Release exposing (Release)
import Model.Wallet exposing (Wallet)


type FromAdminMsg
    = Typing Release String Wallet
    | ViewLedger Wallet
