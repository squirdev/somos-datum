module View.Market.Buy.Buy exposing (body)

import Html exposing (Html)
import Html.Attributes exposing (class, href, style, target)
import Html.Events exposing (onClick)
import Model.Buyer exposing (Buyer(..))
import Model.DownloadStatus as DownloadStatus
import Model.Ledger as Ledger exposing (Ledger)
import Model.Role as User
import Model.Sol as Sol
import Model.State as State exposing (State(..))
import Model.Wallet as PublicKey exposing (Wallet)
import Msg.Anchor exposing (ToAnchorMsg(..))
import Msg.Msg exposing (Msg(..))
import Msg.Phantom exposing (ToPhantomMsg(..))
import View.Market.Ledger exposing (others, yours)


body : Buyer -> Html Msg
body buyer =
    let
        button : Wallet -> Ledger -> Html Msg
        button wallet ledger =
            case Ledger.checkOwnership wallet ledger of
                True ->
                    Html.div
                        []
                        [ Html.button
                            [ class "is-button-1"
                            , style "width" "100%"
                            , onClick (ToPhantom (SignMessage wallet))
                            ]
                            [ Html.text "Download"
                            ]
                        ]

                False ->
                    case Ledger.getMinEscrowItem ledger of
                        -- purchase secondary
                        Just min ->
                            Html.div
                                []
                                [ Html.button
                                    [ class "is-button-1"
                                    , style "width" "100%"
                                    , onClick (ToAnchor (PurchaseSecondary min wallet))
                                    ]
                                    [ Html.text
                                        (String.join
                                            " "
                                            [ "Purchase at minimum resale price:"
                                            , String.fromFloat (Sol.fromLamports min.price)
                                            , "SOL"
                                            ]
                                        )
                                    ]
                                ]

                        -- purchase primary
                        Nothing ->
                            Html.div
                                []
                                [ Html.button
                                    [ class "is-button-1"
                                    , style "width" "100%"
                                    , onClick (ToAnchor (PurchasePrimary wallet))
                                    ]
                                    [ Html.text
                                        (String.join
                                            " "
                                            [ "Purchase:"
                                            , String.fromFloat (Sol.fromLamports ledger.price)
                                            , "SOL"
                                            ]
                                        )
                                    ]
                                ]

        html =
            case buyer of
                WaitingForWallet ->
                    let
                        connect : Html Msg
                        connect =
                            Html.button
                                [ class "is-button-1"
                                , onClick (ToPhantom (Connect User.Buyer))
                                ]
                                [ Html.text "Connect"
                                ]
                    in
                    Html.div
                        [ class "has-border-2"
                        ]
                        [ Html.div
                            [ class "mr-2 mt-2"
                            , style "float" "right"
                            ]
                            [ connect
                            ]
                        , Html.div
                            []
                            [ Html.p
                                [ class "has-font-1 mx-2 mt-2"
                                ]
                                [ Html.div
                                    [ class "mb-6"
                                    ]
                                    [ Html.text "welcome to store.somos.*"
                                    ]
                                , Html.div
                                    [ class "mb-6"
                                    ]
                                    [ Html.text "a decentralized marketplace built on the "
                                    , Html.a
                                        [ class "has-sky-blue-text"
                                        , href "https://solana.com/"
                                        , target "_blank"
                                        ]
                                        [ Html.text "solana blockchain"
                                        ]
                                    ]
                                , Html.div
                                    [ class "mb-6"
                                    ]
                                    [ Html.text
                                        """
                                        where you can buy & sell the
                                        """
                                    , Html.a
                                        [ class "has-sky-blue-text"
                                        , State.href About
                                        ]
                                        [ Html.text "right-to-download"
                                        ]
                                    , Html.text
                                        """
                                         of exclusive releases from your
                                        """
                                    , Html.a
                                        [ class "has-sky-blue-text"
                                        , href "https://www.somos.world/"
                                        , target "_blank"
                                        ]
                                        [ Html.text "favorite band"
                                        ]
                                    ]
                                , Html.div
                                    [ class "mb-6"
                                    ]
                                    [ connect
                                    , Html.text " your wallet to sign-in"
                                    ]
                                ]
                            ]
                        ]

                WaitingForStateLookup publicKey ->
                    let
                        slice_ =
                            PublicKey.slice publicKey
                    in
                    Html.div
                        []
                        [ Html.div
                            [ class "has-border-2 has-font-2 px-2 py-2"
                            , style "float" "right"
                            ]
                            [ Html.text slice_
                            ]
                        , Html.div
                            [ class "is-loading"
                            ]
                            []
                        ]

                Console ledgers ->
                    Html.div
                        []
                        [ header
                        , Html.div
                            []
                            [ Html.text "yours"
                            , Html.div
                                []
                                (yours ledgers (button ledgers.wallet))
                            ]
                        , Html.div
                            []
                            [ Html.text "others"
                            , Html.div
                                []
                                (others ledgers (button ledgers.wallet))
                            ]
                        ]

                Download downloadStatus ->
                    case downloadStatus of
                        DownloadStatus.InvokedAndWaiting phantomSignature ->
                            let
                                slice_ =
                                    PublicKey.slice phantomSignature.userDecoded
                            in
                            Html.div
                                []
                                [ Html.div
                                    [ class "has-border-2 has-font-2 px-2 py-2"
                                    , style "float" "right"
                                    ]
                                    [ Html.text slice_
                                    ]
                                , Html.div
                                    [ class "is-loading"
                                    ]
                                    []
                                ]

                        DownloadStatus.Done response ->
                            let
                                slice_ =
                                    Html.div
                                        [ class "has-border-2 has-font-2 px-2 py-2"
                                        , style "float" "right"
                                        ]
                                        [ Html.text (PublicKey.slice response.user)
                                        ]
                            in
                            Html.div
                                [ class "has-border-2 px-2 pt-2"
                                ]
                                [ slice_
                                , Html.div
                                    [ class "mb-3"
                                    ]
                                    [ Html.h2
                                        []
                                        [ Html.text "authentication complete"
                                        ]
                                    ]
                                , Html.div
                                    [ class "mb-3"
                                    ]
                                    [ Html.text "the download starts automatically in a new tab"
                                    ]
                                , Html.div
                                    [ class "mb-3"
                                    ]
                                    [ Html.text
                                        """
                                        if a new tab did not open, disable your ad / pop-up blocker for this site
                                        and click download again 😎
                                        """
                                    ]
                                , Html.div
                                    [ class "mb-3"
                                    ]
                                    [ Html.button
                                        [ class "is-button-2"
                                        , onClick (ToPhantom (Connect User.Buyer))
                                        ]
                                        [ Html.text "Refresh"
                                        ]
                                    ]
                                ]
    in
    Html.div
        [ class "container"
        ]
        [ html
        ]


header : Html msg
header =
    Html.div
        [ class "has-font-1 py-6"
        ]
        [ Html.div
            [ class "has-border-2 px-2 py-2"
            ]
            [ Html.div
                [ class "pb-2"
                ]
                [ Html.h2
                    []
                    [ Html.text
                        """All releases found here are exclusively available via this marketplace
                        """
                    ]
                ]
            , Html.div
                [ class "has-font-2"
                ]
                [ Html.h3
                    []
                    [ Html.text
                        """these digital assets typically capture moments such as
                        """
                    ]
                , Html.div
                    []
                    [ check
                    , Html.text "singles/EPs intended for our most loyal fans"
                    ]
                , Html.div
                    []
                    [ check
                    , Html.text "live performances"
                    ]
                , Html.div
                    []
                    [ check
                    , Html.text "rough studio takes & footage"
                    ]
                ]
            ]
        ]


check : Html msg
check =
    Html.b
        [ class "has-spacing-1"
        ]
        [ Html.text "☑️"
        ]
