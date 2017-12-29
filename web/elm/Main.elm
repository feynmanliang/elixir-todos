port module Main exposing (..)

import Html
import Models exposing (Model, initialModel)
import Messages exposing (Msg)
import Update exposing (update)
import View exposing (view)
import Subscriptions exposing (subscriptions)
import TokenStorage exposing (doload)


init : ( Model, Cmd Msg )
init =
    ( initialModel, doload () )


main : Program Never Model Msg
main =
    Html.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
