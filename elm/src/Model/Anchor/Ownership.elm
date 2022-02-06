module Model.Anchor.Ownership exposing (Ownership(..))

import Model.Anchor.DownloadStatus exposing (DownloadStatus)
import Model.Anchor.Ledger exposing (Ledger)


type Ownership
    = Console Ledger Int
    | Download DownloadStatus
