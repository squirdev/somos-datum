module Model.State exposing (State(..), href, parse)

import Html
import Html.Attributes
import Model.Anchor exposing (Anchor(..))
import Url
import Url.Parser as UrlParser


type State
    = Market Anchor
    | About
    | Error String


urlParser : UrlParser.Parser (State -> c) c
urlParser =
    UrlParser.oneOf
        [ UrlParser.map (Market WaitingForWallet) UrlParser.top
        , UrlParser.map (Market WaitingForWallet) (UrlParser.s "welcome")
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
        Market _ ->
            "#/welcome"

        About ->
            "#/about"

        Error _ ->
            "#/invalid"


href : State -> Html.Attribute msg
href state =
    Html.Attributes.href (path state)
