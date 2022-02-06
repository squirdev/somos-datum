module View.Market.Sell exposing (body)

import Html exposing (Html)
import Html.Attributes exposing (class, href, target)
import Msg.Msg exposing (Msg)


body : Html Msg
body =
    let
        html =
            Html.div
                [ class "has-font-1 ml-2 mt-2"
                ]
                [ Html.p
                    []
                    [ Html.div
                        [ class "mb-3"
                        ]
                        [ Html.text
                            """
                            the "secondary-market" feature is in
                            """
                        , Html.a
                            [ class "has-sky-blue-text mb-6"
                            , href "https://somos.world/#/roadmap/tech"
                            , target "_blank"
                            ]
                            [ Html.text "active development"
                            ]
                        , Html.text
                            """
                             & will be live before the end of February, 2022
                            """
                        ]
                    ]
                ]
    in
    Html.div
        [ class "container has-border-2"
        ]
        [ html
        ]
