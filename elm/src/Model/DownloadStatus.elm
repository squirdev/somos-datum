module Model.DownloadStatus exposing (DownloadStatus(..))

import Http.Response as Download
import Model.Phantom exposing (PhantomSignature)


type DownloadStatus
    = InvokedAndWaiting PhantomSignature
    | Done Download.Response
