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
import Model.Release as Release
import Model.Role as Role exposing (Role, WithContext)
import Model.Seller as Seller exposing (Seller(..))
import Model.Sol as Sol
import Model.State as State exposing (State(..))
import Model.Wallet as Wallet
import Msg.Admin as FromAdminMsg
import Msg.Anchor exposing (ToAnchorMsg(..))
import Msg.Msg exposing (Msg(..), resetViewport)
import Msg.Phantom exposing (ToPhantomMsg(..))
import Msg.Seller as FromSellerMsg
import Sub.Anchor exposing (getCurrentStateSender, initProgramSender, purchasePrimarySender, purchaseSecondarySender, removeFromEscrowSender, submitToEscrowSender)
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
                Msg.Phantom.GetCurrentState json ->
                    case Role.decode json of
                        Ok role ->
                            case role of
                                Role.BuyerWith moreJson ->
                                    case Wallet.decode moreJson of
                                        Ok wallet ->
                                            ( { model | state = Buy (Buyer.WaitingForStateLookup wallet) }
                                            , getCurrentStateSender json
                                            )

                                        Err error ->
                                            ( { model | state = State.Error error }
                                            , Cmd.none
                                            )

                                Role.SellerWith moreJson ->
                                    case Wallet.decode moreJson of
                                        Ok wallet ->
                                            ( { model | state = Sell (Seller.WaitingForStateLookup wallet) }
                                            , getCurrentStateSender json
                                            )

                                        Err error ->
                                            ( { model | state = State.Error error }
                                            , Cmd.none
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
                InitProgram wallet release ->
                    let
                        json : String
                        json =
                            Role.encode <| Role.AdminWith <| Release.encode wallet release
                    in
                    ( model
                    , initProgramSender json
                    )

                PurchasePrimary wallet recipient role release ->
                    let
                        json : String
                        json =
                            Encode.object
                                [ ( "wallet", Encode.string wallet )
                                , ( "recipient", Encode.string recipient )
                                , ( "release", Encode.int <| Release.toInt release )
                                ]
                                |> Encode.encode 0
                    in
                    case role of
                        Role.Buyer ->
                            ( { model | state = State.Buy <| Buyer.WaitingForStateLookup wallet }
                            , purchasePrimarySender <| Role.encode <| Role.BuyerWith <| json
                            )

                        Role.Seller ->
                            ( { model | state = State.Error "purchase as seller?" }
                            , Cmd.none
                            )

                        Role.Admin ->
                            ( { model | state = State.Admin <| Admin.WaitingForWallet }
                            , purchasePrimarySender <| Role.encode <| Role.AdminWith <| json
                            )

                SubmitToEscrow price ledgers release ->
                    case String.toFloat <| String.trim price of
                        Just float ->
                            let
                                encoder : Encode.Value
                                encoder =
                                    Encode.object
                                        [ ( "wallet", Encode.string ledgers.wallet )
                                        , ( "release", Encode.int <| Release.toInt release )
                                        , ( "price", Encode.int <| Sol.toLamports float )
                                        ]

                                json : String
                                json =
                                    Role.encode (Role.SellerWith (Encode.encode 0 encoder))
                            in
                            ( { model | state = State.Sell (Seller.WaitingForStateLookup ledgers.wallet) }
                            , submitToEscrowSender json
                            )

                        Nothing ->
                            ( { model
                                | state =
                                    State.Sell <| Seller.PriceNotValidFloat release ledgers
                              }
                            , Cmd.none
                            )

                RemoveFromEscrow wallet release ->
                    let
                        encoder : Encode.Value
                        encoder =
                            Encode.object
                                [ ( "wallet", Encode.string wallet )
                                , ( "release", Encode.int <| Release.toInt release )
                                ]

                        json : String
                        json =
                            Role.encode (Role.SellerWith (Encode.encode 0 encoder))
                    in
                    ( { model | state = State.Sell (Seller.WaitingForStateLookup wallet) }
                    , removeFromEscrowSender json
                    )

                PurchaseSecondary escrowItem wallet release ->
                    let
                        encoder : Encode.Value
                        encoder =
                            Encode.object
                                [ ( "wallet", Encode.string wallet )
                                , ( "release", Encode.int <| Release.toInt release )
                                , ( "seller", Encode.string escrowItem.seller )
                                ]

                        json =
                            Role.encode <| Role.BuyerWith <| Encode.encode 0 encoder
                    in
                    ( model
                    , purchaseSecondarySender json
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
                                                Ok ledgers ->
                                                    State.Buy <| Buyer.Console ledgers

                                                Err jsonError ->
                                                    State.Error (Decode.errorToString jsonError)

                                        -- it was the sell page
                                        Role.SellerWith moreJson ->
                                            case Ledger.decode moreJson of
                                                Ok ledgers ->
                                                    State.Sell <| Seller.Console ledgers

                                                Err jsonError ->
                                                    State.Error (Decode.errorToString jsonError)

                                        Role.AdminWith moreJson ->
                                            case Ledger.decode moreJson of
                                                Ok ledgers ->
                                                    State.Admin (Admin.ViewingLedger ledgers)

                                                Err jsonError ->
                                                    State.Error (Decode.errorToString jsonError)

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

                -- purchase secondary
                Msg.Anchor.FailureOnPurchaseSecondary error ->
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
                FromSellerMsg.Typing release string ledgers ->
                    ( { model | state = State.Sell <| Seller.Typing release string ledgers }
                    , Cmd.none
                    )

        FromAdmin administrating ->
            case administrating of
                FromAdminMsg.Typing release string wallet ->
                    ( { model | state = State.Admin <| Admin.Typing release string wallet }
                    , Cmd.none
                    )

                FromAdminMsg.ViewLedger wallet ->
                    ( model
                    , getCurrentStateSender <| Role.encode <| Role.AdminWith <| Wallet.encode wallet
                    )

        FromJsError string ->
            ( { model | state = Error string }
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
