module View.Market.Ledger exposing (others, toList, yours)

import Html exposing (Html)
import Html.Attributes exposing (class, href, target)
import Model.Ledger as Ledger exposing (Ledger, Ledgers)
import Model.Sol as Sol
import Model.Wallet exposing (Wallet)
import Msg.Msg exposing (Msg(..))


body : Args -> Html Msg
body args =
    let
        ownership : Html Msg
        ownership =
            let
                toString : String
                toString =
                    case Ledger.checkOwnership args.wallet args.ledger of
                        True ->
                            "yes 😎"

                        False ->
                            "not yet 😅"
            in
            Html.div
                [ class "my-2"
                ]
                [ Html.p
                    []
                    [ Html.text "ownership: "
                    , Html.b
                        [ class "has-border-2 px-1 py-1"
                        ]
                        [ Html.text toString
                        ]
                    ]
                ]

        min : Html Msg
        min =
            case Ledger.getMinEscrowItem args.ledger of
                Just head ->
                    Html.div
                        [ class "my-2"
                        ]
                        [ Html.p
                            []
                            [ Html.text "minimum resale price: "
                            , Html.b
                                [ class "has-border-2 px-1 py-1"
                                ]
                                [ Html.text <| String.fromFloat <| Sol.fromLamports head.price
                                ]
                            ]
                        ]

                Nothing ->
                    Html.div [] []

        yourPrice : Html Msg
        yourPrice =
            case Ledger.getEscrowItem args.wallet args.ledger of
                Just head ->
                    Html.div
                        [ class "my-2"
                        ]
                        [ Html.p
                            []
                            [ Html.text "your resale price: "
                            , Html.b
                                [ class "has-border-2 px-1 py-1"
                                ]
                                [ Html.text <| String.fromFloat <| Sol.fromLamports head.price
                                ]
                            ]
                        ]

                Nothing ->
                    Html.div [] []
    in
    Html.div
        [ class "has-font-1"
        ]
        [ Html.div
            [ class "has-border-2 px-2 py-2"
            ]
            [ Html.div
                [ class "pl-2"
                ]
                [ Html.div
                    []
                    [ Html.h2
                        []
                        [ Html.text args.meta.header
                        ]
                    ]
                ]
            , args.meta.body
            , Html.div
                [ class "has-border-2 px-2 py-2"
                ]
                [ Html.div
                    [ class "my-2"
                    ]
                    [ Html.p
                        []
                        [ Html.text "original supply remaining: "
                        , Html.b
                            [ class "has-border-2 px-1 py-1"
                            ]
                            [ Html.text (String.fromInt args.ledger.originalSupplyRemaining)
                            ]
                        ]
                    ]
                , Html.div
                    [ class "my-2"
                    ]
                    [ Html.p
                        []
                        [ Html.text "original price: "
                        , Html.b
                            [ class "has-border-2 px-1 py-1"
                            ]
                            [ Html.text <| String.fromFloat <| Sol.fromLamports args.ledger.price
                            ]
                        ]
                    ]
                , min
                , yourPrice
                , ownership
                ]
            , args.local args.ledger
            ]
        ]


type alias Args =
    { wallet : Wallet
    , ledger : Ledger
    , meta : Meta
    , local : Ledger -> Html Msg
    }


type alias Meta =
    { header : String
    , body : Html Msg
    }


toList : Ledgers -> (Ledger -> Html Msg) -> List ( Ledger, Html Msg )
toList ledgers local =
    [ ( ledgers.one, body { wallet = ledgers.wallet, ledger = ledgers.one, meta = release01, local = local } )
    ]


yours : Ledgers -> (Ledger -> Html Msg) -> List (Html Msg)
yours ledgers local =
    List.concatMap
        (\( ledger, html_ ) ->
            case Ledger.checkOwnership ledgers.wallet ledger of
                True ->
                    [ html_ ]

                False ->
                    []
        )
        (toList ledgers local)


others : Ledgers -> (Ledger -> Html Msg) -> List (Html Msg)
others ledgers local =
    List.concatMap
        (\( ledger, html_ ) ->
            case Ledger.checkOwnership ledgers.wallet ledger of
                True ->
                    []

                False ->
                    [ html_ ]
        )
        (toList ledgers local)



-- release 01


release01 : Meta
release01 =
    let
        body_ =
            Html.div
                [ class "has-font-2 has-border-2 px-2 py-2"
                ]
                [ Html.h3
                    []
                    [ Html.a
                        [ class "has-sky-blue-text"
                        , href "https://open.spotify.com/track/2rH6YR5GHba1bPdBlkpmkM?si=8037923a61f34b92"
                        , target "_blank"
                        ]
                        [ Html.text "DAY 02"
                        ]
                    , Html.text
                        """
                         (casa bola live session)
                        """
                    ]
                , Html.div
                    []
                    [ Html.b
                        [ class "mr-2"
                        ]
                        [ Html.text "\u{1F941}"
                        ]
                    , Html.text "audio file"
                    ]
                , Html.div
                    []
                    [ Html.b
                        [ class "mr-2"
                        ]
                        [ Html.text "📸"
                        ]
                    , Html.text "cover photo"
                    ]
                , Html.div
                    []
                    [ Html.text
                        """this live performance of our debut single was recorded (and filmed)
                        at Casa Bola in São Paulo, Brasil.
                        """
                    ]
                ]
    in
    { header = "Release 01"
    , body = body_
    }
