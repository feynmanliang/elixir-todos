module Models exposing (..)

import Date exposing (Date)


type alias AccessToken =
    String


type alias Login =
    { email : String
    , password : String
    , accessToken : Maybe AccessToken
    }


type alias Todo =
    { title : String
    , description : String
    , createdOn : Date
    }


type alias AddTodo =
    { title : String
    , description : String
    }


type alias Model =
    { todoList : List Todo
    , login : Login
    , addTodo : AddTodo
    }


initialModel : Model
initialModel =
    { todoList = []
    , addTodo =
        { title = ""
        , description = ""
        }
    , login =
        { email = ""
        , password = ""
        , accessToken = Nothing
        }
    }
