module Subscriptions exposing (subscriptions)

import Models exposing (Model)
import Messages exposing (LoginMsg(Load), Msg(LoginMsg))
import TokenStorage exposing (load)


subscriptions : Model -> Sub Msg
subscriptions model =
    load Load
        |> Sub.map LoginMsg
