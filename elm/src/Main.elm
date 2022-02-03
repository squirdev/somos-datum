module Main exposing (main)

-- MAIN

import Browser
import Browser.Navigation as Nav
import Http.Download as Download
import Http.Error
import Http.Response
import Json.Decode as Decode
import Json.Encode as Encode
import Model.Anchor as Anchor exposing (Anchor(..), AnchorState, isAccountDoesNotExistError)
import Model.Model as Model exposing (Model)
import Model.Phantom as Phantom
import Model.State as State exposing (State(..))
import Msg.Anchor exposing (ToAnchorMsg(..))
import Msg.Msg exposing (Msg(..), resetViewport)
import Msg.Phantom exposing (ToPhantomMsg(..))
import Sub.Anchor exposing (initProgramSender, isConnectedSender, purchasePrimarySender)
import Sub.Phantom exposing (connectSender, openDownloadUrlSender, signMessageSender)
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
                    ( model
                    , connectSender ()
                    )

                SignMessage user ->
                    ( model
                    , signMessageSender user
                    )

        FromPhantom fromPhantomMsg ->
            case fromPhantomMsg of
                Msg.Phantom.SuccessOnConnection user ->
                    ( { model | state = LandingPage (JustHasWallet user) }
                    , isConnectedSender user
                    )

                Msg.Phantom.ErrorOnConnection string ->
                    ( { model | state = State.Error string }
                    , Cmd.none
                    )

                Msg.Phantom.SuccessOnSignMessage signatureString ->
                    let
                        maybeSignature : Result Decode.Error Phantom.PhantomSignature
                        maybeSignature =
                            Phantom.decodeSignature signatureString
                    in
                    case maybeSignature of
                        Ok signature ->
                            ( { model | state = LandingPage (UserWithOwnershipWaitingForPreSign signature) }
                            , Download.post signature
                            )

                        Err error ->
                            ( { model | state = State.Error (Decode.errorToString error) }
                            , Cmd.none
                            )

                Msg.Phantom.FailureOnSignMessage error ->
                    ( { model | state = State.Error error }
                    , Cmd.none
                    )

        ToAnchor toAnchorMsg ->
            case toAnchorMsg of
                InitProgram user ->
                    ( model
                    , initProgramSender user
                    )

                PurchasePrimary user ->
                    ( model
                    , purchasePrimarySender user
                    )

        FromAnchor fromAnchorMsg ->
            case fromAnchorMsg of
                Msg.Anchor.SuccessOnStateLookup jsonString ->
                    let
                        maybeAnchorState : Result Decode.Error AnchorState
                        maybeAnchorState =
                            Anchor.decodeSuccess jsonString

                        update_ : State
                        update_ =
                            case maybeAnchorState of
                                Ok anchorState ->
                                    let
                                        ownership : Int
                                        ownership =
                                            List.filter
                                                (\pk -> pk == anchorState.user)
                                                anchorState.purchased
                                                |> List.length

                                        user : Anchor
                                        user =
                                            case ownership > 0 of
                                                True ->
                                                    UserWithOwnershipBeforeDownload anchorState ownership

                                                False ->
                                                    UserWithNoOwnership anchorState
                                    in
                                    LandingPage user

                                Err jsonError ->
                                    State.Error (Decode.errorToString jsonError)
                    in
                    ( { model | state = update_ }
                    , Cmd.none
                    )

                Msg.Anchor.FailureOnStateLookup error ->
                    let
                        maybeAnchorStateLookupFailure : Result Decode.Error Anchor.AnchorStateLookupFailure
                        maybeAnchorStateLookupFailure =
                            Anchor.decodeFailure error

                        update_ : State
                        update_ =
                            case maybeAnchorStateLookupFailure of
                                Ok anchorStateLookupFailure ->
                                    case isAccountDoesNotExistError anchorStateLookupFailure.error of
                                        True ->
                                            LandingPage (WaitingForProgramInit anchorStateLookupFailure.user)

                                        False ->
                                            State.Error error

                                Err jsonError ->
                                    State.Error (Decode.errorToString jsonError)
                    in
                    ( { model | state = update_ }, Cmd.none )

                Msg.Anchor.FailureOnInitProgram error ->
                    ( { model | state = State.Error error }, Cmd.none )

                Msg.Anchor.FailureOnPurchasePrimary error ->
                    ( { model | state = State.Error error }, Cmd.none )

        AwsPreSign result ->
            case result of
                Ok response ->
                    let
                        encoder : Encode.Value
                        encoder =
                            Encode.object
                                [ ( "url", Encode.string response.url )
                                , ( "user", Encode.string response.user )
                                ]

                        jsonString : String
                        jsonString =
                            Encode.encode 0 encoder
                    in
                    ( { model | state = LandingPage (UserWithOwnershipWithDownloadUrl response) }
                    , openDownloadUrlSender jsonString
                    )

                Err error ->
                    ( { model | state = State.Error (Http.Error.toString error) }
                    , Cmd.none
                    )



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
