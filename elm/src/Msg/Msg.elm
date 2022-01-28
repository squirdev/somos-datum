module Msg.Msg exposing (Msg(..), resetViewport)

import Browser
import Browser.Dom as Dom
import Msg.Anchor exposing (FromAnchorMsg, ToAnchorMsg)
import Msg.Phantom exposing (FromPhantomMsg, ToPhantomMsg)
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


resetViewport : Cmd Msg
resetViewport =
    Task.perform (\_ -> NoOp) (Dom.setViewport 0 0)
