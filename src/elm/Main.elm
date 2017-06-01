module Main exposing (..)

import Html exposing (program)

import State exposing (..)
import View exposing (view)


main =
  program
    { init = init
    , view = view
    , update = update
    , subscriptions = subscriptions
    }
