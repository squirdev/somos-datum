module View.LandingPage.LandingPage exposing (view)

import Html exposing (Html)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)
import Model.Model exposing (Model)
import Model.Phantom exposing (Phantom(..))
import Msg.Msg exposing (Msg(..))
import Msg.Phantom exposing (ToPhantomMsg(..))
import View.Hero


view : Model -> Html Msg
view model =
    View.Hero.view (body model)


body : Model -> Html Msg
body model =
    let
        phantom =
            case model.phantom of
                Connected pubKey ->
                    Html.text pubKey.pubKey

                NotConnected ->
                    Html.button
                        [ onClick (ToPhantom Connect)
                        ]
                        [ Html.text "Connect"
                        ]
    in
    Html.div
        [ class "container"
        ]
        [ phantom
        ]
