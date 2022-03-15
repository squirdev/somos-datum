module View.Admin.Admin exposing (body)

import Html exposing (Html)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)
import Model.Admin exposing (Admin(..))
import Model.PublicKey exposing (PublicKey)
import Model.User as User
import Msg.Msg exposing (Msg(..))
import Msg.Phantom exposing (ToPhantomMsg(..))

body : Admin -> Html Msg
body admin =
    let
        html =
            case admin of
                WaitingForWallet ->
                    Html.div
                        []
                        [ Html.button
                            [ class "is-button-1"
                            , onClick (ToPhantom (Connect User.Admin))
                            ]
                            [ Html.text "connect"
                            ]
                        ]


                HasWallet publicKey ->
                    case publicKey == boss of
                        True ->
                            Html.div
                                [ class "columns is-multiline"
                                ]
                                [ Html.div
                                    [ class "column has-border-2 is-12"
                                    ]
                                    [ Html.div
                                        []
                                        [ Html.text "release01"
                                        ]
                                    , Html.button
                                        [ class "is-button-1"
                                        ]
                                        [ Html.text "init ledger"
                                        ]
                                    , Html.button
                                        [ class "is-button-1"
                                        ]
                                        [ Html.text "init escrow"
                                        ]
                                    ]
                                ]

                        False ->
                            Html.div
                                []
                                [ Html.text "unauthorized;"
                                ]
    in
    Html.div
        [ class "container"
        ]
        [ html
        ]


boss : PublicKey
boss =
    "DLXRomaskStghSHAyoFZMKnFk1saLYDhYggW25Ze4jug"
