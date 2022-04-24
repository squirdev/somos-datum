module Model.Role exposing (Role(..), WithContext(..), decode, encode, toString)

import Json.Decode as Decode
import Json.Encode as Encode


type Role
    = Buyer
    | Seller
    | Admin


toString : Role -> String
toString user =
    case user of
        Buyer ->
            "buyer"

        Seller ->
            "seller"

        Admin ->
            "admin"


type WithContext
    = BuyerWith Json
    | SellerWith Json
    | AdminWith Json


type alias Json =
    String


type alias Context =
    { role : String -- buyer / seller / admin
    , more : Json -- more json
    }


decode : Json -> Result String WithContext
decode json =
    let
        decoder : Decode.Decoder Context
        decoder =
            Decode.map2 Context
                (Decode.field "role" Decode.string)
                (Decode.field "more" Decode.string)
    in
    case Decode.decodeString decoder json of
        Ok value ->
            case value.role of
                "buyer" ->
                    Ok (BuyerWith value.more)

                "seller" ->
                    Ok (SellerWith value.more)

                "admin" ->
                    Ok (AdminWith value.more)

                _ ->
                    Err "invalid indicator"

        Err error ->
            Err (Decode.errorToString error)


encode : WithContext -> String
encode withContext =
    let
        encoder =
            case withContext of
                BuyerWith json ->
                    Encode.object
                        [ ( "role", Encode.string (toString Buyer) )
                        , ( "more", Encode.string json )
                        ]

                SellerWith json ->
                    Encode.object
                        [ ( "role", Encode.string (toString Seller) )
                        , ( "more", Encode.string json )
                        ]

                AdminWith json ->
                    Encode.object
                        [ ( "role", Encode.string (toString Admin) )
                        , ( "more", Encode.string json )
                        ]
    in
    Encode.encode 0 encoder
