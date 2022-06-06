module Msg.Msg exposing (Msg(..), resetViewport)

import Browser
import Browser.Dom as Dom
import Http
import Http.Response as Download
import Msg.Admin exposing (FromAdminMsg)
import Msg.Anchor exposing (FromAnchorMsg, ToAnchorMsg)
import Msg.Phantom exposing (FromPhantomMsg, ToPhantomMsg)
import Msg.Seller exposing (FromSellerMsg)
import Task
import Url


type Msg
    = NoOp
    | UrlChanged Url.Url
    | LinkClicked Browser.UrlRequest
      -- phantom sub
    | ToPhantom ToPhantomMsg
    | FromPhantom FromPhantomMsg
      -- anchor sub
    | ToAnchor ToAnchorMsg
    | FromAnchor FromAnchorMsg
      -- aws url pre-sign
    | AwsPreSign (Result Http.Error Download.Response)
      -- user forms
    | FromSeller FromSellerMsg
    | FromAdmin FromAdminMsg
      -- generic javascript error
    | FromJsError String


resetViewport : Cmd Msg
resetViewport =
    Task.perform (\_ -> NoOp) (Dom.setViewport 0 0)
