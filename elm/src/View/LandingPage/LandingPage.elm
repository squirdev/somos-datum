module View.LandingPage.LandingPage exposing (view)

import Html exposing (Html)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)
import Model.Anchor exposing (Anchor(..))
import Msg.Anchor exposing (ToAnchorMsg(..))
import Msg.Msg exposing (Msg(..))
import Msg.Phantom exposing (ToPhantomMsg(..))
import View.Hero


view : Anchor -> Html Msg
view anchor =
    View.Hero.view (body anchor)


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

                UserWithOwnershipBeforeDownload anchorState count ->
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

                UserWithOwnershipWaitingForPreSign signature ->
                    Html.div
                        []
                        [ Html.div
                            []
                            [ Html.text signature.userDecoded
                            ]
                        , Html.div
                            []
                            [ Html.text "waiting for pre-signed url"
                            ]
                        ]

                UserWithOwnershipWithDownloadUrl response ->
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
