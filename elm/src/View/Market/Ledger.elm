module View.Market.Ledger exposing (Args, body)

import Html exposing (Html)
import Html.Attributes exposing (class, href, style, target)
import Model.Ledger as Ledger exposing (Ledger)
import Model.Sol as Sol
import Model.Wallet as PublicKey
import Msg.Msg exposing (Msg(..))


type alias Args =
    { ledger : Ledger
    , html : Html Msg
    }


body : Args -> Html Msg
body args =
    let
        slice_ =
            Html.div
                [ class "has-border-2 has-font-2 px-2 py-2"
                , style "float" "right"
                ]
                [ Html.text (PublicKey.slice args.ledger.wallet)
                ]

        ownership : Html Msg
        ownership =
            let
                toString : String
                toString =
                    case Ledger.checkOwnership args.ledger of
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

        yours : Html Msg
        yours =
            case Ledger.getEscrowItem args.ledger of
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
            [ class "pl-2"
            ]
            [ Html.div
                []
                [ Html.h2
                    []
                    [ Html.text "Release 01"
                    ]
                ]
            ]
        , Html.div
            [ class "has-border-2 px-2 py-2"
            ]
            [ slice_
            , Html.div
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
            , Html.div
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
            , yours
            , ownership
            , args.html
            ]
        ]
