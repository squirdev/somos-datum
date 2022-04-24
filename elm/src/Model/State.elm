module Model.State exposing (State(..), href, parse)

import Html
import Html.Attributes
import Model.Admin as Admin exposing (Admin)
import Model.Buyer as Buyer exposing (Buyer)
import Model.Seller as Seller exposing (Seller)
import Url
import Url.Parser as UrlParser


type State
    = Buy Buyer
    | Sell Seller
    | About
    | Admin Admin
    | Error String


urlParser : UrlParser.Parser (State -> c) c
urlParser =
    UrlParser.oneOf
        [ UrlParser.map (Buy Buyer.WaitingForWallet) UrlParser.top
        , UrlParser.map (Buy Buyer.WaitingForWallet) (UrlParser.s "buy")
        , UrlParser.map (Sell Seller.WaitingForWallet) (UrlParser.s "sell")
        , UrlParser.map (Admin Admin.WaitingForWallet) (UrlParser.s "admin")
        , UrlParser.map About (UrlParser.s "about")
        ]


parse : Url.Url -> State
parse url =
    let
        target =
            -- The RealWorld spec treats the fragment like a path.
            -- This makes it *literally* the path, so we can proceed
            -- with parsing as if it had been a normal path all along.
            { url | path = Maybe.withDefault "" url.fragment, fragment = Nothing }
    in
    case UrlParser.parse urlParser target of
        Just state ->
            state

        Nothing ->
            Error "404; Invalid Path"


path : State -> String
path state =
    case state of
        Buy _ ->
            "#/buy"

        Sell _ ->
            "#/sell"

        About ->
            "#/about"

        Admin _ ->
            "#/admin"

        Error _ ->
            "#/invalid"


href : State -> Html.Attribute msg
href state =
    Html.Attributes.href (path state)
