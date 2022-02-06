module View.Market.Buy.Primary exposing (body)

import Html exposing (Html)
import Html.Attributes exposing (class, href, style, target)
import Html.Events exposing (onClick)
import Model.Anchor.Anchor exposing (Anchor(..))
import Model.Anchor.DownloadStatus as DownloadStatus
import Model.Anchor.Ownership as Ownership
import Model.PublicKey as PublicKey
import Model.State as State exposing (State(..))
import Msg.Anchor exposing (ToAnchorMsg(..))
import Msg.Msg exposing (Msg(..))
import Msg.Phantom exposing (ToPhantomMsg(..))
import View.Market.LoggedIn as LoggedIn
import View.Market.Ownership


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
                            [ style "float" "right"
                            ]
                            [ button
                            ]
                        , Html.div
                            []
                            [ Html.p
                                [ class "has-font-1 ml-2 mt-2"
                                ]
                                [ Html.div
                                    [ class "mb-6"
                                    ]
                                    [ Html.text "welcome to store.somos.*"
                                    ]
                                , Html.div
                                    [ class "mb-6"
                                    ]
                                    [ Html.text "a decentralized market place built on the "
                                    , Html.a
                                        [ class "has-sky-blue-text"
                                        , href "https://solana.com/"
                                        , target "_blank"
                                        ]
                                        [ Html.text "solana blockchain"
                                        ]
                                    ]
                                , Html.div
                                    [ class "mb-6"
                                    ]
                                    [ button
                                    , Html.text " your wallet to sign-in & begin interacting with the market place"
                                    ]
                                , Html.div
                                    [ class "mb-6"
                                    ]
                                    [ Html.text
                                        """
                                        where you can buy & sell the
                                        """
                                    , Html.a
                                        [ class "has-sky-blue-text"
                                        , State.href About
                                        ]
                                        [ Html.text "right-to-download"
                                        ]
                                    , Html.text
                                        """
                                         of exclusive content from some of your
                                        """
                                    , Html.a
                                        [ class "has-sky-blue-text"
                                        , href "https://www.somos.world/"
                                        , target "_blank"
                                        ]
                                        [ Html.text "favorite creatives"
                                        ]
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
                                    Html.div
                                        []
                                        [ Html.div
                                            []
                                            [ Html.text phantomSignature.userDecoded
                                            ]
                                        , Html.div
                                            []
                                            [ Html.text "waiting for pre-signed url"
                                            ]
                                        ]

                                DownloadStatus.Done response ->
                                    Html.div
                                        []
                                        [ Html.div
                                            []
                                            [ Html.text response.user
                                            ]
                                        , Html.div
                                            []
                                            [ Html.text "downloaded"
                                            ]
                                        ]
    in
    Html.div
        [ class "container"
        ]
        [ html
        ]
