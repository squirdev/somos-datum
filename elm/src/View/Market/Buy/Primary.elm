module View.Market.Buy.Primary exposing (body)

import Html exposing (Html)
import Html.Attributes exposing (class, href, style, target)
import Html.Events exposing (onClick)
import Model.Anchor.Anchor exposing (Anchor(..))
import Model.Anchor.DownloadStatus as DownloadStatus
import Model.Anchor.Ownership as Ownership
import Model.State as State exposing (State(..))
import Msg.Anchor exposing (ToAnchorMsg(..))
import Msg.Msg exposing (Msg(..))
import Msg.Phantom exposing (ToPhantomMsg(..))


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
                            slice publicKey
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
                    let
                        slice_ =
                            Html.div
                                [ class "has-border-2 has-font-2 px-2 py-2"
                                , style "float" "right"
                                ]
                                [ Html.text (slice ledger.user)
                                ]
                    in
                    Html.div
                        [ class "has-font-1"
                        ]
                        [ Html.div
                            [ class "pl-2"
                            ]
                            [ Html.div
                                []
                                [ Html.h2
                                    []
                                    [ Html.text "release 01"
                                    ]
                                ]
                            ]
                        , Html.div
                            [ class "has-border-2 px-2 py-2"
                            ]
                            [ slice_
                            , Html.div
                                [ class "has-font-2"
                                ]
                                [ Html.h3
                                    []
                                    [ Html.text
                                        """
                                        "DAY 02" (casa bola live session)
                                        """
                                    ]
                                , Html.div
                                    []
                                    [ Html.b
                                        [ class "mr-2"
                                        ]
                                        [ Html.text "\u{1F941}"
                                        ]
                                    , Html.text "audio file"
                                    ]
                                , Html.div
                                    []
                                    [ Html.b
                                        [ class "mr-2"
                                        ]
                                        [ Html.text "📸"
                                        ]
                                    , Html.text "cover photo"
                                    ]
                                ]
                            , Html.div
                                [ class "columns is-mobile mt-2"
                                ]
                                [ Html.div
                                    [ class "column"
                                    ]
                                    [ Html.p
                                        []
                                        [ Html.text "original supply remaining: "
                                        , Html.b
                                            [ class "has-border-2 px-1 py-1"
                                            ]
                                            [ Html.text (String.fromInt ledger.originalSupplyRemaining)
                                            ]
                                        ]
                                    ]
                                ]
                            , Html.div
                                []
                                [ Html.button
                                    [ class "is-button-2"
                                    , onClick (ToAnchor (PurchasePrimary ledger.user))
                                    ]
                                    [ Html.text "Purchase"
                                    ]
                                ]
                            ]
                        ]

                UserWithOwnership ownership ->
                    case ownership of
                        Ownership.Console anchorState count ->
                            Html.div
                                []
                                [ Html.div
                                    [ class "columns is-mobile"
                                    ]
                                    [ Html.div
                                        [ class "column"
                                        ]
                                        [ Html.text
                                            (String.join
                                                ": "
                                                [ "Original Supply Remaining"
                                                , String.fromInt anchorState.originalSupplyRemaining
                                                ]
                                            )
                                        ]
                                    , Html.div
                                        [ class "column"
                                        ]
                                        [ Html.text
                                            (String.join
                                                ": "
                                                [ "Your Ownership"
                                                , String.fromInt count
                                                ]
                                            )
                                        ]
                                    , Html.div
                                        []
                                        [ Html.button
                                            [ onClick (ToPhantom (SignMessage anchorState.user))
                                            ]
                                            [ Html.text "Download"
                                            ]
                                        ]
                                    ]
                                , Html.div
                                    []
                                    [ Html.button
                                        [ onClick (ToAnchor (PurchasePrimary anchorState.user))
                                        ]
                                        [ Html.text "Purchase More"
                                        ]
                                    ]
                                ]

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


type alias PublicKey =
    String


slice : PublicKey -> PublicKey
slice publicKey =
    String.join
        "..."
        [ String.slice 0 4 publicKey
        , String.slice -5 -1 publicKey
        ]
