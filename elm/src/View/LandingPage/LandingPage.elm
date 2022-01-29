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
                            [ Html.text "still need to init program"
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
                                [ onClick (ToAnchor PurchasePrimary)
                                ]
                                [ Html.text "Purchase"
                                ]
                            ]
                        ]
    in
    Html.div
        [ class "container"
        ]
        [ state
        ]
