module View.Market.Market exposing (Args, body)

import Html exposing (Html)
import Html.Attributes exposing (class, href, style, target)
import Model.Ledger exposing (Ledger)
import Model.Wallet as PublicKey
import Msg.Msg exposing (Msg(..))


type alias Args =
    { ledger : Ledger
    , ownership : Bool -- TODO; check internally
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
                toString : Bool -> String
                toString bool =
                    case bool of
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
                        [ Html.text (toString args.ownership)
                        ]
                    ]
                ]
    in
    Html.div
        [ class "has-font-1"
        ]
        [ Html.div
            [ class "py-6"
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
                            """all releases found here are exclusively available via this marketplace
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
        , Html.div
            [ class "pl-2"
            ]
            [ Html.div
                []
                [ Html.h2
                    []
                    [ Html.text "release 01"
                    ]
                ]
            ]
        , Html.div
            [ class "has-border-2 px-2 py-2"
            ]
            [ slice_
            , Html.div
                [ class "has-font-2"
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
            , ownership
            , args.html
            ]
        ]


check : Html msg
check =
    Html.b
        [ class "has-spacing-1"
        ]
        [ Html.text "☑️"
        ]
