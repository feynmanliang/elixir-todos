module Main exposing (..)

import Html exposing (text, Html, div)
import Html.Attributes exposing (class)
import Components.TodoList as TodoList


type alias Model =
    { todoListModel : TodoList.Model }


type Msg
    = TodoListMsg TodoList.Msg


initialModel : Model
initialModel =
    { todoListModel = TodoList.initialModel }


init : ( Model, Cmd Msg )
init =
    ( initialModel, Cmd.none )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        TodoListMsg todoMsg ->
            let
                ( updatedModel, cmd ) =
                    TodoList.update todoMsg model.todoListModel
            in
                ( { model | todoListModel = updatedModel }, Cmd.map TodoListMsg cmd )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


view : Model -> Html Msg
view model =
    div [ class "elm-app" ]
        [ Html.map TodoListMsg (TodoList.view model.todoListModel) ]


main : Program Never Model Msg
main =
    Html.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
