module View.Market.Buy.Buy exposing (body)

import Html exposing (Html)
import Html.Attributes exposing (class, href, style, target)
import Html.Events exposing (onClick)
import Model.Buyer exposing (Buyer(..))
import Model.DownloadStatus as DownloadStatus
import Model.Ledger as Ledger exposing (Ledger)
import Model.Role as User exposing (Role(..))
import Model.Seller as Seller
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
                                    , onClick (ToAnchor (PurchaseSecondary min wallet ledger.release))
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
                                    , onClick (ToAnchor (PurchasePrimary wallet ledger.release))
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

                WaitingForStateLookup wallet ->
                    Html.div
                        []
                        [ slice_ wallet
                        , Html.div
                            [ class "is-loading"
                            ]
                            []
                        ]

                Console ledgers ->
                    let
                        yours_ =
                            case yours ledgers (button ledgers.wallet) of
                                [] ->
                                    Html.div
                                        [ class "pb-6"
                                        ]
                                        [ Html.div
                                            [ class "has-border-2 px-2 py-2"
                                            ]
                                            [ Html.h2
                                                [ class "has-font-1 has-border-1 mb-2"
                                                ]
                                                [ Html.text "Your collection"
                                                ]
                                            , Html.div
                                                []
                                                [ Html.div
                                                    [ class "has-font-2"
                                                    ]
                                                    [ Html.text "nothing here yet \u{1F97A}"
                                                    ]
                                                , Html.div
                                                    [ class "has-font-2"
                                                    ]
                                                    [ Html.text
                                                        """check out the available releases below
                                                        """
                                                    ]
                                                ]
                                            ]
                                        ]

                                nel ->
                                    Html.div
                                        [ class "pb-6"
                                        ]
                                        [ Html.div
                                            [ class "has-border-2 px-2 py-2"
                                            ]
                                            [ Html.h2
                                                [ class "has-font-1 has-border-1 mb-2"
                                                ]
                                                [ Html.text "Your collection"
                                                ]
                                            , Html.div
                                                [ class "pb-2"
                                                ]
                                                [ Html.div
                                                    [ class "has-font-2"
                                                    ]
                                                    [ Html.text "ready for download 💿️️"
                                                    ]
                                                , Html.div
                                                    [ class "has-font-2"
                                                    ]
                                                    [ Html.p
                                                        []
                                                        [ Html.text "ready for "
                                                        , Html.a
                                                            [ class "has-sky-blue-text"
                                                            , State.href (State.Sell <| Seller.WaitingForStateLookup ledgers.wallet)
                                                            , onClick (ToPhantom (Connect User.Seller))
                                                            ]
                                                            [ Html.text "re-sell"
                                                            ]
                                                        , Html.text " 💰"
                                                        ]
                                                    ]
                                                ]
                                            , Html.div
                                                []
                                                nel
                                            ]
                                        ]

                        others_ =
                            case others ledgers (button ledgers.wallet) of
                                [] ->
                                    Html.div
                                        [ class "has-border-2 px-2 py-2"
                                        ]
                                        [ Html.h2
                                            [ class "has-font-1 has-border-1 mb-2"
                                            ]
                                            [ Html.text "Available releases not in your collection"
                                            ]
                                        , Html.div
                                            []
                                            [ Html.div
                                                [ class "has-font-2"
                                                ]
                                                [ Html.text
                                                    """this is empty because you've purchased every release available ♥️
                                                    """
                                                ]
                                            , Html.div
                                                [ class "has-font-2"
                                                ]
                                                [ Html.text
                                                    """go download and consider re-selling for a profit
                                                    """
                                                ]
                                            ]
                                        ]

                                nel ->
                                    Html.div
                                        [ class "has-border-2 px-2 py-2"
                                        ]
                                        [ Html.h2
                                            [ class "has-font-1 has-border-1 mb-2"
                                            ]
                                            [ Html.text "Available releases not in your collection"
                                            ]
                                        , Html.div
                                            []
                                            nel
                                        ]
                    in
                    Html.div
                        []
                        [ header ledgers.wallet
                        , yours_
                        , others_
                        ]

                Download downloadStatus ->
                    case downloadStatus of
                        DownloadStatus.InvokedAndWaiting phantomSignature ->
                            Html.div
                                []
                                [ slice_ phantomSignature.userDecoded
                                , Html.div
                                    [ class "is-loading"
                                    ]
                                    []
                                ]

                        DownloadStatus.Done response ->
                            Html.div
                                [ class "has-border-2 px-2 pt-2"
                                ]
                                [ slice_ response.user
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


header : Wallet -> Html Msg
header wallet =
    Html.div
        [ class "has-font-1 py-6"
        ]
        [ Html.div
            [ class "has-border-2 px-2 py-2"
            ]
            [ slice_ wallet
            , Html.div
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


slice_ : Wallet -> Html Msg
slice_ wallet =
    Html.div
        [ class "has-border-2 has-font-2 px-2 py-2 ml-1"
        , style "float" "right"
        ]
        [ Html.text (PublicKey.slice wallet)
        ]


check : Html msg
check =
    Html.b
        [ class "has-spacing-1"
        ]
        [ Html.text "☑️"
        ]
