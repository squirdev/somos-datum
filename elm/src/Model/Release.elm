module Model.Release exposing (Release(..), encode, fromInt, toInt)

import Json.Encode as Encode
import Model.Wallet exposing (Wallet)


type Release
    = One
    | Two
    | Nil


encode : Wallet -> Release -> String
encode wallet release =
    let
        encoder =
            Encode.object
                [ ( "wallet", Encode.string wallet )
                , ( "release", Encode.int <| toInt release )
                ]
    in
    Encode.encode 0 encoder


toInt : Release -> Int
toInt release =
    case release of
        One ->
            1

        Two ->
            2

        Nil ->
            -1


fromInt : Int -> Release
fromInt int =
    case int of
        1 ->
            One

        2 ->
            Two

        _ ->
            Nil
