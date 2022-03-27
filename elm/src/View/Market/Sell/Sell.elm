module View.Market.Sell.Sell exposing (body)

import Html exposing (Html)
import Html.Attributes exposing (class, href, placeholder, style, target, type_)
import Html.Events exposing (onClick, onInput)
import Model.Buyer as Buyer
import Model.Ledger exposing (Ledger, Ledgers)
import Model.Role as User exposing (Role(..))
import Model.Seller exposing (Seller(..))
import Model.State as State exposing (State(..))
import Model.Wallet as PublicKey exposing (Wallet)
import Msg.Anchor exposing (ToAnchorMsg(..))
import Msg.Msg exposing (Msg(..))
import Msg.Phantom exposing (ToPhantomMsg(..))
import Msg.Seller as FromSellerMsg
import View.Market.Ledger exposing (yours)


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

                WaitingForStateLookup wallet ->
                    Html.div
                        [ class "has-border-2"
                        ]
                        [ slice_ wallet
                        , Html.div
                            [ class "is-loading"
                            ]
                            []
                        ]

                Console ledgers ->
                    let
                        button : Ledger -> Html Msg
                        button ledger =
                            Html.div
                                [ class "has-border-2"
                                ]
                                [ Html.button
                                    [ class "is-button-1"
                                    , style "width" "100%"
                                    , onClick (FromSeller <| FromSellerMsg.Typing "" ledgers)
                                    ]
                                    [ Html.text "type your price here"
                                    ]
                                ]
                    in
                    body_ ledgers button

                Typing string ledgers ->
                    let
                        price =
                            case string of
                                "" ->
                                    "_._"

                                _ ->
                                    string

                        input : Ledger -> Html Msg
                        input ledger =
                            Html.div
                                [ class "field has-border-2"
                                ]
                                [ Html.p
                                    [ class "control has-icons-left has-icons-right"
                                    ]
                                    [ Html.input
                                        [ class "input is-focused is-link is-small"
                                        , type_ "text"
                                        , placeholder "your price in SOL"
                                        , onInput (\str -> FromSeller (FromSellerMsg.Typing str ledgers))
                                        ]
                                        []
                                    , Html.span
                                        [ class "icon is-small is-left"
                                        ]
                                        [ Html.i
                                            [ class "fas fa-dollar-sign"
                                            ]
                                            []
                                        ]
                                    ]
                                , Html.button
                                    [ class "is-button-1"
                                    , style "width" "100%"
                                    , onClick (ToAnchor (SubmitToEscrow price ledgers))
                                    ]
                                    [ Html.text <|
                                        String.join " " [ "submit to escrow at:", price, "SOL" ]
                                    ]
                                ]
                    in
                    body_ ledgers input

                PriceNotValidFloat ledgers ->
                    let
                        button : Ledger -> Html Msg
                        button ledger =
                            Html.div
                                [ class "has-border-2"
                                ]
                                [ Html.button
                                    [ class "is-button-1"
                                    , style "width" "100%"
                                    , onClick (FromSeller <| FromSellerMsg.Typing "" ledgers)
                                    ]
                                    [ Html.text "try again with a valid numeric value"
                                    ]
                                ]
                    in
                    body_ ledgers button
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


header : Wallet -> Html Msg
header wallet =
    Html.div
        [ class "has-font-1 py-6"
        ]
        [ Html.div
            [ class "has-border-2 px-2 py-2"
            ]
            [ slice_ wallet
            , Html.div
                [ class "pb-2"
                ]
                [ Html.h2
                    []
                    [ Html.text
                        """Re-sell marketplace
                        """
                    ]
                ]
            , Html.div
                [ class "has-font-2"
                ]
                [ Html.div
                    []
                    [ Html.text
                        """transactions are facilitated
                        """
                    , Html.a
                        [ class "has-sky-blue-text"
                        , target "_blank"
                        , href "https://github.com/bigtimetapin/somos-solana/blob/develop/programs/somos-solana/src/lib.rs"
                        ]
                        [ Html.text "securely"
                        ]
                    , Html.text " on the solana blockchain"
                    ]
                ]
            ]
        ]


slice_ : Wallet -> Html Msg
slice_ wallet =
    Html.div
        [ class "has-border-2 has-font-2 px-2 py-2 ml-1"
        , style "float" "right"
        ]
        [ Html.text (PublicKey.slice wallet)
        ]


body_ : Ledgers -> (Ledger -> Html Msg) -> Html Msg
body_ ledgers local =
    let
        yours_ =
            case yours ledgers local of
                [] ->
                    Html.div
                        []
                        [ header ledgers.wallet
                        , Html.div
                            [ class "has-border-2 px-2 py-2"
                            ]
                            [ Html.h2
                                [ class "has-font-1 has-border-1 mb-2"
                                ]
                                [ Html.text "Your collection"
                                ]
                            , Html.div
                                [ class "has-font-2"
                                ]
                                [ Html.text "is empty 😭"
                                ]
                            , Html.div
                                [ class "has-font-2"
                                ]
                                [ Html.p
                                    []
                                    [ Html.text "go check out our "
                                    , Html.a
                                        [ class "has-sky-blue-text"
                                        , State.href (State.Buy <| Buyer.WaitingForStateLookup ledgers.wallet)
                                        , onClick (ToPhantom (Connect User.Buyer))
                                        ]
                                        [ Html.text "available releases"
                                        ]
                                    , Html.text " 😉"
                                    ]
                                ]
                            ]
                        ]

                nel ->
                    Html.div
                        []
                        [ header ledgers.wallet
                        , Html.div
                            [ class "has-border-2 px-2 py-2"
                            ]
                            [ Html.h2
                                [ class "has-font-1 has-border-1 mb-2"
                                ]
                                [ Html.text "Your collection"
                                ]
                            , Html.div
                                [ class "pb-2"
                                ]
                                [ Html.div
                                    [ class "has-font-2"
                                    ]
                                    [ Html.text "specify your re-sell price ✏️"
                                    ]
                                , Html.div
                                    [ class "has-font-2"
                                    ]
                                    [ Html.text "make a profit 💯"
                                    ]
                                ]
                            , Html.div
                                []
                                nel
                            ]
                        ]
    in
    yours_
