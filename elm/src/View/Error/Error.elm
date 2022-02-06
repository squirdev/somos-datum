module View.Error.Error exposing (body)

import Html exposing (Html)
import Html.Attributes exposing (class)
import Msg.Msg exposing (Msg)


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
