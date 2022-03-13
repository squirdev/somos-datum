module Model.Sol exposing (Sol, fromLamports)

import Model.Lamports exposing (Lamports)


type alias Sol =
    Float


fromLamports : Lamports -> Sol
fromLamports lamports =
    (toFloat lamports) / lamportsPerSol



{- 1 billion -}


lamportsPerSol : Float
lamportsPerSol =
    1000000000.0
