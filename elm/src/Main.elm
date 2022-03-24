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
import Model.Phantom as Phantom
import Model.Role as Role exposing (Role, WithContext)
import Model.Seller as Seller exposing (Seller(..))
import Model.State as State exposing (State(..))
import Model.Wallet as Wallet
import Msg.Anchor exposing (ToAnchorMsg(..))
import Msg.Msg exposing (Msg(..), resetViewport)
import Msg.Phantom exposing (ToPhantomMsg(..))
import Msg.Seller as FromSellerMsg
import Sub.Anchor exposing (getCurrentStateSender, initProgramSender, purchasePrimarySender, submitToEscrowSender)
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
                Connect role ->
                    ( model
                    , connectSender (Role.toString role)
                    )

                SignMessage user ->
                    ( model
                    , signMessageSender user
                    )

        FromPhantom fromPhantomMsg ->
            case fromPhantomMsg of
                Msg.Phantom.SuccessOnConnection json ->
                    case Role.decode json of
                        Ok role ->
                            case role of
                                Role.BuyerWith wallet ->
                                    ( { model | state = Buy (Buyer.WaitingForStateLookup wallet) }
                                    , getCurrentStateSender json
                                    )

                                Role.SellerWith wallet ->
                                    ( { model | state = Sell (Seller.WaitingForStateLookup wallet) }
                                    , getCurrentStateSender json
                                    )

                                Role.AdminWith moreJson ->
                                    case Wallet.decode moreJson of
                                        Ok wallet ->
                                            ( { model | state = Admin (Admin.HasWallet wallet) }
                                            , Cmd.none
                                            )

                                        Err error ->
                                            ( { model | state = State.Error error }
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
                                        Buyer.Download <|
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
                InitProgram wallet ->
                    ( model
                    , initProgramSender (Role.encode (Role.AdminWith (Wallet.encode wallet)))
                    )

                PurchasePrimary wallet ->
                    let
                        json : String
                        json =
                            Role.encode (Role.BuyerWith (Wallet.encode wallet))
                    in
                    ( model
                      -- TODO; waiting state
                    , purchasePrimarySender json
                    )

                SubmitToEscrow ledger price ->
                    case String.toFloat <| String.trim price of
                        Just float ->
                            let
                                encoder : Encode.Value
                                encoder =
                                    Encode.object
                                        [ ( "wallet", Encode.string ledger.wallet )
                                        , ( "price", Encode.float float )
                                        ]

                                json : String
                                json =
                                    Role.encode (Role.SellerWith (Encode.encode 0 encoder))
                            in
                            ( { model | state = State.Sell (Seller.WaitingForStateLookup ledger.wallet) }
                            , submitToEscrowSender json
                            )

                        Nothing ->
                            ( { model
                                | state =
                                    State.Sell <| Seller.PriceNotValidFloat ledger
                              }
                            , Cmd.none
                            )

        FromAnchor fromAnchorMsg ->
            case fromAnchorMsg of
                -- state lookup
                Msg.Anchor.SuccessOnStateLookup json ->
                    let
                        maybeRole : Result String Role.WithContext
                        maybeRole =
                            Role.decode json

                        update_ : State
                        update_ =
                            case maybeRole of
                                -- client connected via buy or sell pages
                                -- we don't know yet which page it was
                                Ok role ->
                                    case role of
                                        -- it was the buy page
                                        Role.BuyerWith moreJson ->
                                            case Ledger.decode moreJson of
                                                Ok ledger ->
                                                    State.Buy <| Buyer.Console ledger

                                                Err jsonError ->
                                                    State.Error (Decode.errorToString jsonError)

                                        -- it was the sell page
                                        Role.SellerWith moreJson ->
                                            case Ledger.decode moreJson of
                                                Ok ledger ->
                                                    State.Sell <| Seller.Console ledger

                                                Err jsonError ->
                                                    State.Error (Decode.errorToString jsonError)

                                        Role.AdminWith wallet ->
                                            State.Admin (Admin.HasWallet wallet)

                                Err error ->
                                    State.Error error
                    in
                    ( { model | state = update_ }
                    , Cmd.none
                    )

                Msg.Anchor.FailureOnStateLookup error ->
                    ( { model | state = State.Error error }, Cmd.none )

                -- init program
                Msg.Anchor.FailureOnInitProgram error ->
                    ( { model | state = State.Error error }, Cmd.none )

                -- purchase primary
                Msg.Anchor.FailureOnPurchasePrimary error ->
                    ( { model | state = State.Error error }, Cmd.none )

                -- submit to escrow
                Msg.Anchor.FailureOnSubmitToEscrow error ->
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
                    ( { model | state = Buy (Buyer.Download (DownloadStatus.Done response)) }
                    , openDownloadUrlSender jsonString
                    )

                Err error ->
                    ( { model | state = State.Error (Http.Error.toString error) }
                    , Cmd.none
                    )

        FromSeller selling ->
            case selling of
                FromSellerMsg.Typing string ledger ->
                    ( { model | state = State.Sell <| Seller.Typing string ledger }
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
