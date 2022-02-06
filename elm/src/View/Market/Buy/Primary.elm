module View.Market.Buy.Primary exposing (body)

import Html exposing (Html)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)
import Model.Anchor.Anchor exposing (Anchor(..))
import Model.Anchor.DownloadStatus as DownloadStatus
import Model.Anchor.Ownership as Ownership
import Msg.Anchor exposing (ToAnchorMsg(..))
import Msg.Msg exposing (Msg(..))
import Msg.Phantom exposing (ToPhantomMsg(..))


body : Anchor -> Html Msg
body anchor =
    let
        state =
            case anchor of
                WaitingForWallet ->
                    Html.button
                        [ onClick (ToPhantom Connect)
                        ]
                        [ Html.text "Connect"
                        ]

                JustHasWallet publicKey ->
                    Html.div
                        []
                        [ Html.div
                            []
                            [ Html.text publicKey
                            ]
                        , Html.div
                            []
                            [ Html.text "what next?"
                            ]
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

                UserWithNoOwnership anchorState ->
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
                            ]
                        , Html.div
                            []
                            [ Html.button
                                [ onClick (ToAnchor (PurchasePrimary anchorState.user))
                                ]
                                [ Html.text "Purchase"
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
        [ state
        ]
