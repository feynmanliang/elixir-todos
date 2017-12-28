module Todo exposing (view, Model)

import Html exposing (Html, span, strong, em, a, text)
import Html.Attributes exposing (class)


type alias Model =
    { title : String
    , description : String
    , ownedBy : String
    , createdOn : String
    }


view : Model -> Html a
view model =
    span [ class "todo" ]
        [ strong [] [ text model.title ]
        , span [] [ text (" Owned by: " ++ model.ownedBy) ]
        , em [] [ text (" (created on : " ++ model.createdOn ++ ")") ]
        ]
