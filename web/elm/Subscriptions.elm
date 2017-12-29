module Subscriptions exposing (subscriptions)

import Models exposing (Model)
import Messages exposing (Msg(Load))
import TokenStorage exposing (load)


subscriptions : Model -> Sub Msg
subscriptions model =
    load Load
