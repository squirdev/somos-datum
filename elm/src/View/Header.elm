module View.Header exposing (view)

import Html exposing (Html)
import Html.Attributes exposing (class, src, style, width)
import Html.Events exposing (onClick)
import Model.Admin as Admin
import Model.Buyer as Buyer exposing (Buyer(..))
import Model.Seller as Seller
import Model.Model exposing (Model)
import Model.State as State exposing (State(..))
import Model.User as User
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
                Buy buyer ->
                    Buyer.getPublicKey buyer

                Sell seller ->
                    Seller.getPublicKey seller

                About ->
                    Nothing

                Admin admin ->
                    Admin.getPublicKey admin

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
                        { state = Buy (Buyer.WaitingForStateLookup publicKey)
                        , title = title
                        , msg = ToPhantom (Connect User.Buyer)
                        }

                Nothing ->
                    tab_
                        { state = Buy Buyer.WaitingForWallet
                        , title = title
                        , msg = NoOp
                        }

        sell : Html Msg
        sell =
            let
                title =
                    "SELL"
            in
            case maybePublicKey of
                Just publicKey ->
                    tab_
                        { state = Sell (Seller.WaitingForStateLookup publicKey)
                        , title = title
                        , msg = ToPhantom (Connect User.Seller)
                        }

                Nothing ->
                    tab_
                        { state = Sell Seller.WaitingForWallet
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
        , sell
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
    case state of
        Buy _ ->
            case model.state of
                Buy _ ->
                    class_

                _ ->
                    ""

        Sell _ ->
            case model.state of
                Sell _ ->
                    class_
                _ ->
                    ""

        _ ->
            case model.state == state of
                True ->
                    class_

                False ->
                    ""
