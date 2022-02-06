module Model.Anchor.Ownership exposing (Ownership(..))

import Model.Anchor.AnchorState exposing (AnchorState)
import Model.Anchor.DownloadStatus exposing (DownloadStatus)


type Ownership
    = Console AnchorState Int
    | Download DownloadStatus
