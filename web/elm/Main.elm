port module Main exposing (..)

import Html exposing (text, Html, div)
import Html.Attributes exposing (class)
import Components.TodoList as TodoList
import Components.LoginForm as LoginForm


type alias Model =
    { todoListModel : TodoList.Model
    , loginFormModel : LoginForm.Model
    }


type Msg
    = TodoListMsg TodoList.Msg
    | LoginFormMsg LoginForm.Msg


initialModel : Model
initialModel =
    { todoListModel = TodoList.initialModel
    , loginFormModel = LoginForm.initialModel
    }


init : Maybe Model -> ( Model, Cmd Msg )
init model =
    case model of
        Just model ->
            ( model, Cmd.none )

        Nothing ->
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

        LoginFormMsg loginMsg ->
            let
                ( updatedModel, cmd ) =
                    LoginForm.update loginMsg model.loginFormModel
            in
                ( { model | loginFormModel = updatedModel }, (Cmd.map LoginFormMsg cmd) )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


view : Model -> Html Msg
view model =
    div [ class "elm-app" ]
        [ Html.map TodoListMsg (TodoList.view model.todoListModel)
        , Html.map LoginFormMsg (LoginForm.view model.loginFormModel)
        ]


main : Program (Maybe Model) Model Msg
main =
    Html.programWithFlags
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


setStorageHelper : Model -> ( Model, Cmd Msg )
setStorageHelper model =
    ( model, setStorage model )


port setStorage : Model -> Cmd msg


port removeStorage : Model -> Cmd msg
