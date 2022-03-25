module Model.Sol exposing (Sol, fromLamports, toLamports)

import Model.Lamports exposing (Lamports)


type alias Sol =
    Float


fromLamports : Lamports -> Sol
fromLamports lamports =
    toFloat lamports / lamportsPerSol


toLamports : Sol -> Lamports
toLamports sol =
    floor <| sol * lamportsPerSol



{- 1 billion -}


lamportsPerSol : Float
lamportsPerSol =
    1000000000.0
