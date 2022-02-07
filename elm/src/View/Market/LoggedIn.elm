module View.Market.LoggedIn exposing (Args, body)

import Html exposing (Html)
import Html.Attributes exposing (class, style)
import Html.Events exposing (onClick)
import Model.Anchor.Ledger exposing (Ledger)
import Model.PublicKey as PublicKey
import Msg.Anchor exposing (ToAnchorMsg(..))
import Msg.Msg exposing (Msg(..))
import Msg.Phantom exposing (ToPhantomMsg(..))
import View.Market.Ownership exposing (Ownership(..))


type alias Args =
    { ledger : Ledger
    , ownership : Ownership
    }


body : Args -> Html Msg
body args =
    let
        slice_ =
            Html.div
                [ class "has-border-2 has-font-2 px-2 py-2"
                , style "float" "right"
                ]
                [ Html.text (PublicKey.slice args.ledger.user)
                ]

        purchase =
            case args.ownership of
                Yes count ->
                    case count == 1 of
                        True ->
                            Html.div
                                []
                                [ Html.button
                                    [ class "is-button-1"
                                    , style "width" "100%"
                                    , onClick (ToAnchor (PurchasePrimary args.ledger.user))
                                    ]
                                    [ Html.text (String.join ": " ["Purchase 2nd Copy", "0.025 SOL"]) -- todo; from ledger
                                    ]
                                ]

                        False ->
                            Html.div [] []

                No ->
                    Html.div
                        []
                        [ Html.button
                            [ class "is-button-1"
                            , style "width" "100%"
                            , onClick (ToAnchor (PurchasePrimary args.ledger.user))
                            ]
                            [ Html.text (String.join ": " ["Purchase", "0.025 SOL"]) -- todo; from ledger
                            ]
                        ]

        maybeCount =
            case args.ownership of
                Yes int ->
                    Html.div
                        [ class "my-2"
                        ]
                        [ Html.p
                            []
                            [ Html.text "your ownership: "
                            , Html.b
                                [ class "has-border-2 px-1 py-1"
                                ]
                                [ Html.text (String.fromInt int)
                                ]
                            ]
                        ]

                No ->
                    Html.div [] []

        maybeDownload =
            case args.ownership of
                Yes _ ->
                    Html.div
                        []
                        [ Html.button
                            [ class "is-button-1"
                            , style "width" "100%"
                            , onClick (ToPhantom (SignMessage args.ledger.user))
                            ]
                            [ Html.text "Download"
                            ]
                        ]

                No ->
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
                    [ Html.text
                        """
                        "DAY 02" (casa bola live session)
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
            , maybeCount
            , maybeDownload
            , purchase
            ]
        ]
