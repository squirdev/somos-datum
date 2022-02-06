module View.Header exposing (view)

import Html exposing (Html)
import Html.Attributes exposing (class, src, style, width)
import Html.Events exposing (onClick)
import Model.Anchor as Anchor exposing (Anchor(..))
import Model.Model exposing (Model)
import Model.State as State exposing (State(..))
import Msg.Msg exposing (Msg(..))
import Msg.Phantom exposing (ToPhantomMsg(..))


view : Model -> Html Msg
view model =
    let
        tab_ : Args -> Html Msg
        tab_ =
            tab model

        maybePublicKey : Maybe String
        maybePublicKey =
            case model.state of
                Buy anchor ->
                    Anchor.getPublicKey anchor

                About ->
                    Nothing

                Error _ ->
                    Nothing

        buy : Html Msg
        buy =
            let
                title =
                    "BUY"
            in
            case maybePublicKey of
                Just publicKey ->
                    tab_
                        { state = Buy (JustHasWallet publicKey)
                        , title = title
                        , msg = ToPhantom Connect
                        }

                Nothing ->
                    tab_
                        { state = Buy WaitingForWallet
                        , title = title
                        , msg = NoOp
                        }
    in
    Html.nav
        [ class "is-navbar"
        ]
        [ tab_
            { state = About
            , title = "ABOUT"
            , msg = NoOp
            }
        , buy
        , Html.div
            [ style "float" "right"
            ]
            [ Html.a
                [ State.href About
                ]
                [ Html.img
                    [ src "images/logo/02_somos.png"
                    , width 50
                    ]
                    []
                ]
            ]
        ]


type alias Args =
    { state : State
    , title : String
    , msg : Msg
    }


tab : Model -> Args -> Html Msg
tab model args =
    Html.div
        [ style "float" "left"
        ]
        [ Html.a
            [ State.href args.state
            , onClick args.msg
            ]
            [ Html.button
                [ class (String.join " " [ "has-font-1", "is-button-1", isActive model args.state ])
                ]
                [ Html.text args.title
                ]
            ]
        ]


isActive : Model -> State -> String
isActive model state =
    let
        class_ =
            "is-active-header-tab"
    in
    case model.state == state of
        True ->
            class_

        False ->
            ""
