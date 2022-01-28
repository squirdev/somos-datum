module Main exposing (main)

-- MAIN

import Browser
import Browser.Navigation as Nav
import Model.Anchor exposing (Anchor(..))
import Model.Model as Model exposing (Model)
import Model.State as State exposing (State(..))
import Msg.Anchor exposing (ToAnchorMsg(..))
import Msg.Msg exposing (Msg(..), resetViewport)
import Msg.Phantom exposing (ToPhantomMsg(..))
import Sub.Anchor exposing (isConnectedSender)
import Sub.Phantom exposing (connectSender)
import Sub.Sub as Sub
import Url
import View.About.About
import View.Error.Error
import View.LandingPage.LandingPage


main : Program () Model Msg
main =
    Browser.application
        { init = Model.init
        , view = view
        , update = update
        , subscriptions = \_ -> Sub.subs
        , onUrlChange = UrlChanged
        , onUrlRequest = LinkClicked
        }



-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        UrlChanged url ->
            ( { model
                | state = State.parse url
                , url = url
              }
            , resetViewport
            )

        LinkClicked urlRequest ->
            case urlRequest of
                Browser.Internal url ->
                    ( model, Nav.pushUrl model.key (Url.toString url) )

                Browser.External href ->
                    ( model, Nav.load href )

        ToPhantom toPhantomMsg ->
            case toPhantomMsg of
                Connect ->
                    ( model, connectSender () )

        FromPhantom fromPhantomMsg ->
            case fromPhantomMsg of
                Msg.Phantom.SuccessOnConnection pubKey ->
                    ( { model | state = LandingPage (JustHasWallet pubKey) }
                    , isConnectedSender ()
                    )

                Msg.Phantom.ErrorOnConnection string ->
                    ( { model | state = Error string }
                    , Cmd.none
                    )

        ToAnchor toAnchorMsg ->
            case toAnchorMsg of
                TODO ->
                    ( model, Cmd.none )

        FromAnchor fromAnchorMsg ->
            case fromAnchorMsg of
                Msg.Anchor.SuccessOnStateLookup jsonString ->
                    ( { model | state = LandingPage (Ready { json = jsonString }) }
                    , Cmd.none
                    )

                Msg.Anchor.FailureOnStateLookup string ->
                    ( { model | state = Error string }, Cmd.none )



-- VIEW


view : Model -> Browser.Document Msg
view model =
    let
        html =
            case model.state of
                LandingPage anchor ->
                    View.LandingPage.LandingPage.view anchor

                About ->
                    View.About.About.view

                Error error ->
                    View.Error.Error.view error
    in
    { title = "Responsive Elm"
    , body =
        [ html
        ]
    }
