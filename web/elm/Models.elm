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


type alias Model =
    { todoList : List Todo
    , login : Login
    }


initialModel : Model
initialModel =
    { todoList = []
    , login =
        { email = ""
        , password = ""
        , accessToken = Nothing
        }
    }
