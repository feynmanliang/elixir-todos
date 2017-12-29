port module TokenStorage exposing (..)

import Models exposing (AccessToken)


port save : String -> Cmd msg


port load : (Maybe AccessToken -> msg) -> Sub msg


port doload : () -> Cmd msg


port remove : () -> Cmd msg
