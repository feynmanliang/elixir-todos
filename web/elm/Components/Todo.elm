module Todo exposing (view, Model)

import Date exposing (Date)
import Html exposing (Html, span, strong, em, a, text)
import Html.Attributes exposing (class)


type alias Model =
    { title : String
    , description : String
    , createdOn : Date
    }


view : Model -> Html a
view model =
    span [ class "todo" ]
        [ strong [] [ text model.title ]
        , em [] [ text (" (created on : " ++ (toString model.createdOn) ++ ")") ]
        ]
