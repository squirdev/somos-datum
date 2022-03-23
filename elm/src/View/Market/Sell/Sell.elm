module View.Market.Sell.Sell exposing (body)

import Html exposing (Html)
import Html.Attributes exposing (class, href, placeholder, style, type_)
import Html.Events exposing (onClick, onInput)
import Model.Ledger exposing (Ledger)
import Model.Role as User exposing (Role(..))
import Model.Seller as Seller exposing (Seller(..))
import Model.State as State exposing (State(..))
import Model.Wallet as PublicKey
import Msg.Anchor exposing (ToAnchorMsg(..))
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
                        [ class "has-border-2"
                        ]
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
                    case ownership of
                        Seller.Console ledger ->
                            let
                                button =
                                    Html.div
                                        []
                                        [ Html.button
                                            [ class "is-button-3"
                                            , onClick (FromSeller <| Seller.Typing "" ledger)
                                            ]
                                            [ Html.text "type your price here"
                                            ]
                                        ]
                            in
                            View.Market.Market.body
                                { ledger = ledger
                                , ownership = True
                                , html = button
                                }

                        Seller.Sell selling ->
                            case selling of
                                Seller.Typing string ledger ->
                                    let
                                        price =
                                            case string of
                                                "" ->
                                                    "_._"

                                                _ ->
                                                    string

                                        input =
                                            Html.div
                                                [ class "field"
                                                ]
                                                [ Html.p
                                                    [ class "control has-icons-left has-icons-right"
                                                    ]
                                                    [ Html.input
                                                        [ class "input is-focused is-link is-small"
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
                                                , Html.button
                                                    [ class "is-button-3"
                                                    , onClick (ToAnchor (SubmitToEscrow ledger price))
                                                    ]
                                                    [ Html.text <|
                                                        String.join " " [ "submit to escrow at:", price, "SOL" ]
                                                    ]
                                                ]
                                    in
                                    View.Market.Market.body
                                        { ledger = ledger
                                        , ownership = True
                                        , html = input
                                        }

                                Seller.PriceNotValidFloat ledger ->
                                    let
                                        button =
                                            Html.div
                                                []
                                                [ Html.button
                                                    [ class "is-button-3"
                                                    , onClick (FromSeller <| Seller.Typing "" ledger)
                                                    ]
                                                    [ Html.text "try again with a valid numeric value"
                                                    ]
                                                ]
                                    in
                                    View.Market.Market.body
                                        { ledger = ledger
                                        , ownership = True
                                        , html = button
                                        }

                                -- TODO; success sub
                                Seller.Done wallet ->
                                    Html.div [] []

                WithoutOwnership ledger ->
                    View.Market.Market.body
                        { ledger = ledger
                        , ownership = False
                        , html = Html.div [] []
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
