module View.Market.Sell.Sell exposing (body)

import Html exposing (Html)
import Html.Attributes exposing (class, href, style, target)
import Html.Events exposing (onClick)
import Model.Anchor.Anchor as Anchor exposing (Anchor(..))
import Model.Anchor.DownloadStatus as DownloadStatus
import Model.Anchor.Ownership as Ownership
import Model.PublicKey as PublicKey
import Model.State as State exposing (State(..))
import Msg.Anchor exposing (ToAnchorMsg(..))
import Msg.Msg exposing (Msg(..))
import Msg.Phantom exposing (ToPhantomMsg(..))
import View.Market.Ownership
import View.Market.Sell.LoggedIn as LoggedIn


body : Anchor -> Html Msg
body anchor =
    let
        html =
            case anchor of
                WaitingForWallet ->
                    let
                        button : Html Msg
                        button =
                            Html.button
                                [ class "is-button-1"
                                , onClick (ToPhantom Connect)
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

                JustHasWallet publicKey ->
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

                WaitingForProgramInit publicKey ->
                    Html.div
                        []
                        [ Html.div
                            []
                            [ Html.text publicKey
                            ]
                        , Html.div
                            []
                            [ Html.button
                                [ onClick (ToAnchor (InitProgram publicKey))
                                ]
                                [ Html.text "Init"
                                ]
                            ]
                        ]

                UserWithNoOwnership ledger ->
                    LoggedIn.body { ledger = ledger, ownership = View.Market.Ownership.No }

                UserWithOwnership ownership ->
                    case ownership of
                        Ownership.Console ledger count ->
                            LoggedIn.body { ledger = ledger, ownership = View.Market.Ownership.Yes count }

                        Ownership.Download downloadStatus ->
                            case downloadStatus of
                                DownloadStatus.InvokedAndWaiting phantomSignature ->
                                    let
                                        slice_ =
                                            PublicKey.slice phantomSignature.userDecoded
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

                                DownloadStatus.Done response ->
                                    let
                                        slice_ =
                                            Html.div
                                                [ class "has-border-2 has-font-2 px-2 py-2"
                                                , style "float" "right"
                                                ]
                                                [ Html.text (PublicKey.slice response.user)
                                                ]
                                    in
                                    Html.div
                                        [ class "has-border-2 px-2 pt-2"
                                        ]
                                        [ slice_
                                        , Html.div
                                            [ class "mb-3"
                                            ]
                                            [ Html.h2
                                                []
                                                [ Html.text "authentication complete"
                                                ]
                                            ]
                                        , Html.div
                                            [ class "mb-3"
                                            ]
                                            [ Html.text "the download starts automatically in a new tab"
                                            ]
                                        , Html.div
                                            [ class "mb-3"
                                            ]
                                            [ Html.text
                                                """
                                                if a new tab did not open, disable your ad / pop-up blocker for this site
                                                and click download again 😎
                                                """
                                            ]
                                        , Html.div
                                            [ class "mb-3"
                                            ]
                                            [ Html.button
                                                [ class "is-button-2"
                                                , onClick (ToPhantom Connect)
                                                ]
                                                [ Html.text "Refresh"
                                                ]
                                            ]
                                        ]
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
