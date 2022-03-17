module Main exposing (main)

-- MAIN

import Browser
import Browser.Navigation as Nav
import Html exposing (Html)
import Http.Download as Download
import Http.Error
import Http.Response
import Json.Decode as Decode
import Json.Encode as Encode
import Model.Admin as Admin
import Model.Buyer as Buyer exposing (Buyer)
import Model.DownloadStatus as DownloadStatus
import Model.Ledger as Ledger exposing (Ledger)
import Model.Model as Model exposing (Model)
import Model.Ownership as Ownership
import Model.Phantom as Phantom
import Model.Seller as Seller
import Model.State as State exposing (State(..))
import Model.User as User exposing (User, WithContext)
import Msg.Anchor exposing (ToAnchorMsg(..))
import Msg.Msg exposing (Msg(..), resetViewport)
import Msg.Phantom exposing (ToPhantomMsg(..))
import Sub.Anchor exposing (getCurrentStateSender, initProgramSender, purchasePrimarySender)
import Sub.Phantom exposing (connectSender, openDownloadUrlSender, signMessageSender)
import Sub.Sub as Sub
import Url
import View.About.About
import View.Admin.Admin
import View.Error.Error
import View.Hero
import View.Market.Buy.Buy
import View.Market.Sell.Sell


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
                Connect user ->
                    ( model
                    , connectSender (User.toString user)
                    )

                SignMessage user ->
                    ( model
                    , signMessageSender user
                    )

        FromPhantom fromPhantomMsg ->
            case fromPhantomMsg of
                Msg.Phantom.SuccessOnConnection json ->
                    case User.decode json of
                        Ok user ->
                            case user of
                                User.BuyerWith publicKey ->
                                    ( { model | state = Buy (Buyer.WaitingForStateLookup publicKey) }
                                    , getCurrentStateSender json
                                    )

                                User.SellerWith publicKey ->
                                    ( { model | state = Sell (Seller.WaitingForStateLookup publicKey) }
                                    , getCurrentStateSender json
                                    )

                                User.AdminWith publicKey ->
                                    ( { model | state = Admin (Admin.HasWallet publicKey) }
                                    , Cmd.none
                                    )

                        Err error ->
                            ( { model | state = State.Error error }
                            , Cmd.none
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
                            ( { model
                                | state =
                                    Buy <|
                                        Buyer.WithOwnership <|
                                            Ownership.Download <|
                                                DownloadStatus.InvokedAndWaiting signature
                              }
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
                    , initProgramSender (User.encode user)
                    )

                PurchasePrimary user ->
                    let
                        json : String
                        json =
                            User.encode (User.BuyerWith user)
                    in
                    ( model
                    , purchasePrimarySender json
                    )

        FromAnchor fromAnchorMsg ->
            case fromAnchorMsg of
                Msg.Anchor.SuccessOnStateLookup json ->
                    let
                        maybeUser : Result String User.WithContext
                        maybeUser =
                            User.decode json

                        update_ : State
                        update_ =
                            case maybeUser of
                                -- client connected via buy or sell pages
                                -- we don't know yet which page it was
                                Ok user ->
                                    case user of
                                        -- it was the buy page
                                        User.BuyerWith moreJson ->
                                            case Ledger.decodeSuccess moreJson of
                                                Ok ledger ->
                                                    case Ledger.checkOwnership ledger of
                                                        True ->
                                                            State.Buy <|
                                                             Buyer.WithOwnership <|
                                                                Ownership.Console ledger

                                                        False ->
                                                            State.Buy (Buyer.WithoutOwnership ledger)

                                                Err jsonError ->
                                                    State.Error (Decode.errorToString jsonError)

                                        -- it was the sell page
                                        User.SellerWith moreJson ->
                                            -- TODO; Escrow model
                                            State.Sell (Seller.WithoutOwnership "pubkey")

                                        User.AdminWith publicKey ->
                                            State.Admin (Admin.HasWallet publicKey)

                                Err error ->
                                    State.Error error
                    in
                    ( { model | state = update_ }
                    , Cmd.none
                    )

                Msg.Anchor.FailureOnStateLookup error ->
                    let
                        maybeLedgerLookupFailure : Result Decode.Error Ledger.LedgerLookupFailure
                        maybeLedgerLookupFailure =
                            -- TODO; drop in favor of admin init
                            Ledger.decodeFailure error

                        update_ : State
                        update_ =
                            case maybeLedgerLookupFailure of
                                Ok anchorStateLookupFailure ->
                                    case Ledger.isAccountDoesNotExistError anchorStateLookupFailure.error of
                                        True ->
                                            Buy (Buyer.NeedsToInitProgram anchorStateLookupFailure.user)

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
                    ( { model | state = Buy (Buyer.WithOwnership (Ownership.Download (DownloadStatus.Done response))) }
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
        hero : Html Msg -> Html Msg
        hero =
            View.Hero.view model

        html =
            case model.state of
                Buy buyer ->
                    hero (View.Market.Buy.Buy.body buyer)

                Sell seller ->
                    hero (View.Market.Sell.Sell.body seller)

                About ->
                    hero View.About.About.body

                Admin admin ->
                    hero (View.Admin.Admin.body admin)

                Error error ->
                    hero (View.Error.Error.body error)
    in
    { title = "store.somos.world"
    , body =
        [ html
        ]
    }
