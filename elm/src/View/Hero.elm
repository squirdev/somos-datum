module View.Hero exposing (view)

import Html exposing (Html)
import Html.Attributes exposing (class)
import Msg.Msg exposing (Msg)
import View.Footer
import View.Header


view : Html Msg -> Html Msg
view body =
    Html.section
        [ class "hero is-fullheight"
        ]
        [ Html.div
            [ class "hero-head"
            ]
            [ View.Header.view
            ]
        , Html.div
            [ class "hero-body"
            ]
            [ body
            ]
        , Html.div
            [ class "hero-foot"
            ]
            [ View.Footer.view
            ]
        ]
