module Models exposing (..)

import Date exposing (Date)


type alias AccessToken =
    String


type alias Login =
    { email : String
    , password : String
    , loggedIn : Bool
    }


type alias Todo =
    { title : String
    , description : String
    , createdOn : Date
    }


type alias Model =
    { todoList : List Todo
    , login : Login
    , accessToken : Maybe AccessToken
    }


initialModel : Model
initialModel =
    { todoList = []
    , login =
        { email = ""
        , password = ""
        , loggedIn = False
        }
    , accessToken = Nothing
    }
