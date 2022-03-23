module View.Admin.Admin exposing (body)

import Html exposing (Html)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)
import Model.Admin exposing (Admin(..))
import Model.Role as User
import Model.Wallet exposing (Wallet)
import Msg.Anchor exposing (ToAnchorMsg(..))
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

                HasWallet wallet ->
                    case wallet == boss of
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
                                        , onClick (ToAnchor (InitProgram wallet))
                                        ]
                                        [ Html.text "init"
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


boss : Wallet
boss =
    "DLXRomaskStghSHAyoFZMKnFk1saLYDhYggW25Ze4jug"
