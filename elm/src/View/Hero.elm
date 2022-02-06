module View.Hero exposing (view)

import Html exposing (Html)
import Html.Attributes exposing (class)
import Model.Model exposing (Model)
import Msg.Msg exposing (Msg)
import View.Footer
import View.Header


view : Model -> Html Msg -> Html Msg
view model body =
    Html.section
        [ class "hero is-fullheight has-black"
        ]
        [ Html.div
            [ class "hero-head"
            ]
            [ View.Header.view model
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
