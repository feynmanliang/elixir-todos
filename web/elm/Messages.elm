module Messages exposing (..)

import Http
import Models exposing (AccessToken, Todo)


type TodoListMsg
    = NoOp
    | Fetch
    | FetchCompleted (Result Http.Error (List Todo))


type LoginMsg
    = ClickSubmit
    | ClickLogout
    | SetEmail String
    | SetPassword String
    | GetTokenCompleted (Result Http.Error String)
    | DoLoad
    | Load (Maybe AccessToken)


type Msg
    = TodoListMsg TodoListMsg
    | LoginMsg LoginMsg
