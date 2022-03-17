module Model.Ownership exposing (Ownership(..))

import Model.DownloadStatus exposing (DownloadStatus)
import Model.Ledger exposing (Ledger)


type Ownership
    = Console Ledger
    | Download DownloadStatus
