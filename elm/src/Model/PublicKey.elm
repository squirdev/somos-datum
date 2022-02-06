module Model.PublicKey exposing (PublicKey, slice)

type alias PublicKey =
    String


slice : PublicKey -> PublicKey
slice publicKey =
    String.join
        "..."
        [ String.slice 0 4 publicKey
        , String.slice -5 -1 publicKey
        ]
