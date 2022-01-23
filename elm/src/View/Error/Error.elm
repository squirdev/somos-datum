module View.Error.Error exposing (view)

import Html exposing (Html)
import Html.Attributes exposing (class)
import Msg.Msg exposing (Msg)
import View.Hero


view : String -> Html Msg
view error =
    View.Hero.view (body error)


body : String -> Html Msg
body error =
    Html.div
        [ class "container"
        ]
        [ Html.div
            []
            [ Html.text error
            ]
        ]
