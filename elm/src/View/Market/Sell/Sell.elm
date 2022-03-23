module View.Market.Sell.Sell exposing (body)

import Html exposing (Html)
import Html.Attributes exposing (class, href, placeholder, style, type_)
import Html.Events exposing (onClick, onInput)
import Model.Ledger exposing (Ledger)
import Model.Wallet as PublicKey
import Model.Seller as Seller exposing (Seller(..))
import Model.State as State exposing (State(..))
import Model.Role as User exposing (Role(..))
import Msg.Msg exposing (Msg(..))
import Msg.Phantom exposing (ToPhantomMsg(..))
import View.Market.Market


body : Seller -> Html Msg
body seller =
    let
        html =
            case seller of
                WaitingForWallet ->
                    let
                        button : Html Msg
                        button =
                            Html.button
                                [ class "is-button-1"
                                , onClick (ToPhantom (Connect User.Seller))
                                ]
                                [ Html.text "Connect"
                                ]
                    in
                    Html.div
                        [ class "has-border-2"
                        ]
                        [ Html.div
                            [ class "mr-2 mt-2"
                            , style "float" "right"
                            ]
                            [ button
                            ]
                        , Html.div
                            []
                            [ Html.p
                                [ class "has-font-1 mx-2 mt-2"
                                ]
                                [ Html.div
                                    [ class "mb-6"
                                    ]
                                    [ Html.text "ownership console"
                                    ]
                                , Html.div
                                    [ class "mb-6"
                                    ]
                                    [ Html.text
                                        """here you can re-sell any of the
                                        """
                                    , Html.a
                                        [ class "has-sky-blue-text"
                                        , State.href About
                                        ]
                                        [ Html.text "right-to-download"
                                        ]
                                    , Html.text
                                        """
                                        purchases that you've made
                                        """
                                    ]
                                , Html.div
                                    [ class "mb-6"
                                    ]
                                    [ Html.ul
                                        []
                                        [ Html.li
                                            [ class "mb-3"
                                            ]
                                            [ check
                                            , Html.text
                                                """you set the re-sell price
                                                """
                                            ]
                                        , Html.li
                                            [ class "mb-3"
                                            ]
                                            [ check
                                            , Html.text
                                                """ownership is transferred securely on the
                                                """
                                            , Html.a
                                                [ class "has-sky-blue-text"
                                                , href "https://solana.com/"
                                                ]
                                                [ Html.text "solana blockchain"
                                                ]
                                            , Html.text " from you to the buyer"
                                            ]
                                        , Html.li
                                            [ class "mb-3"
                                            ]
                                            [ check
                                            , Html.text
                                                """95% of the re-sell price is transferred to your wallet
                                                """
                                            ]
                                        , Html.li
                                            [ class "mb-3"
                                            ]
                                            [ check
                                            , Html.text
                                                """5% is transferred to the artists ♥️
                                                """
                                            ]
                                        ]
                                    ]
                                , Html.div
                                    [ class "mb-6"
                                    ]
                                    [ button
                                    , Html.text " your wallet to sign-in"
                                    ]
                                ]
                            ]
                        ]

                WaitingForStateLookup publicKey ->
                    let
                        slice_ =
                            PublicKey.slice publicKey
                    in
                    Html.div
                        []
                        [ Html.div
                            [ class "has-border-2 has-font-2 px-2 py-2"
                            , style "float" "right"
                            ]
                            [ Html.text slice_
                            ]
                        , Html.div
                            [ class "is-loading"
                            ]
                            []
                        ]

                WithOwnership ownership ->
                    let
                        input : Ledger -> Html Msg
                        input ledger =
                            Html.div
                                [ class "field"
                                ]
                                [ Html.p
                                    [ class "control has-icons-left"
                                    ]
                                    [ Html.input
                                        [ class "input is-focused is-link"
                                        , type_ "text"
                                        , placeholder "your price in SOL"
                                        , onInput (\str -> FromSeller (Seller.Typing str ledger))
                                        ]
                                        []
                                    , Html.span
                                        [ class "icon is-small is-left"
                                        ]
                                        [ Html.i
                                            [ class "fas fa-envelope"
                                            ]
                                            []
                                        ]
                                    ]
                                ]
                    in
                    case ownership of
                        Seller.Console ledger ->
                            let
                                foo = ""
                            in
                            View.Market.Market.body
                                { ledger = ledger
                                , ownership = True
                                , button = input ledger
                                }



                        Seller.Sell selling ->
                            case selling of
                                Seller.Typing string ledger ->
                                    input ledger

                                Seller.PriceDecided string ledger ->
                                    Html.div [] []

                                Seller.PriceIsValidFloat float ledger ->
                                    Html.div [] []

                                Seller.PriceNotValidFloat ledger ->
                                    Html.div [] []

                                Seller.Done ledger ->
                                    Html.div [] []

                WithoutOwnership ledger ->
                    View.Market.Market.body
                        { ledger = ledger
                        , ownership = False
                        , button = Html.div [] []
                        }
    in
    Html.div
        [ class "container"
        ]
        [ html
        ]


check : Html msg
check =
    Html.b
        [ class "has-spacing-1"
        ]
        [ Html.text "☑️"
        ]
