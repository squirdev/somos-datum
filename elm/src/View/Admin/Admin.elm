module View.Admin.Admin exposing (body)

import Html exposing (Html)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick, onInput)
import Model.Admin exposing (Admin(..))
import Model.Release as Release exposing (Release(..))
import Model.Role as User exposing (Role(..))
import Model.Wallet exposing (Wallet)
import Msg.Admin as FromAdminMsg
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
                                    , Html.div
                                        []
                                        [ Html.button
                                            [ class "is-button-1"
                                            , onClick (ToAnchor (InitProgram wallet One))
                                            ]
                                            [ Html.text "init"
                                            ]
                                        ]
                                    , Html.div
                                        []
                                        [ Html.button
                                            [ class "is-button-1"
                                            , onClick (FromAdmin <| FromAdminMsg.Typing One "" wallet)
                                            ]
                                            [ Html.text "buy for other"
                                            ]
                                        ]
                                    ]

                                --, Html.div
                                --    [ class "column has-border-2 is-12"
                                --    ]
                                --    [ Html.div
                                --        []
                                --        [ Html.text "release02"
                                --        ]
                                --    , Html.div
                                --        []
                                --        [ Html.button
                                --            [ class "is-button-1"
                                --            , onClick (ToAnchor (InitProgram wallet Two))
                                --            ]
                                --            [ Html.text "init"
                                --            ]
                                --        ]
                                --    , Html.div
                                --        []
                                --        [ Html.button
                                --            [ class "is-button-1"
                                --            , onClick (FromAdmin <| FromAdminMsg.Typing Two "" wallet)
                                --            ]
                                --            [ Html.text "buy for other"
                                --            ]
                                --        ]
                                --    ]
                                , Html.div
                                    [ class "column has-border-2 is-12"
                                    ]
                                    [ Html.div
                                        []
                                        [ Html.button
                                            [ class "is-button-1"
                                            , onClick (FromAdmin <| FromAdminMsg.ViewLedger wallet)
                                            ]
                                            [ Html.text "view ledgers"
                                            ]
                                        ]
                                    ]
                                ]

                        False ->
                            Html.div
                                []
                                [ Html.text "unauthorized;"
                                ]

                Typing release string wallet ->
                    Html.div
                        [ class "has-border-2"
                        ]
                        [ Html.h2
                            []
                            [ Html.text <| String.concat [ "release: ", String.fromInt (Release.toInt release) ]
                            ]
                        , Html.div
                            []
                            [ Html.input
                                [ onInput (\s -> FromAdmin <| FromAdminMsg.Typing release s wallet)
                                ]
                                []
                            ]
                        , Html.div
                            []
                            [ Html.button
                                [ class "is-button-1"
                                , onClick (ToAnchor <| PurchasePrimary wallet string Admin release)
                                ]
                                [ Html.text <| String.concat [ "buy for: ", string ]
                                ]
                            ]
                        ]

                ViewingLedger ledgers ->
                    let
                        vi_ : Wallet -> Html Msg
                        vi_ wallet =
                            Html.div
                                []
                                [ Html.text wallet
                                ]
                    in
                    Html.div
                        []
                        [ Html.div
                            [ class "has-border-2"
                            ]
                            [ Html.div
                                []
                                [ Html.text "ledger: one"
                                ]
                            , Html.div
                                []
                                (List.map
                                    vi_
                                    ledgers.one.owners
                                )
                            ]

                        -- , Html.div
                        --     [ class "has-border-2"
                        --     ]
                        --     [ Html.div
                        --         []
                        --         [ Html.text "ledger: two"
                        --         ]
                        --     , Html.div
                        --         []
                        --         (List.map
                        --             vi_
                        --             ledgers.two.owners
                        --         )
                        --     ]
                        ]
    in
    Html.div
        [ class "container"
        ]
        [ html
        ]


boss : Wallet
boss =
    "DEuG4JnzvMVxMFPoBVvf2GH38mn3ybunMxtfmVU3ms86"
