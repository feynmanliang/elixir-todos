port module Main exposing (..)

import Html exposing (text, Html, div)
import Html.Attributes exposing (class)
import Components.TodoList as TodoList
import Components.LoginForm as LoginForm exposing (Msg(..))


type alias Model =
    { todoListModel : TodoList.Model
    , loginFormModel : LoginForm.Model
    , accessToken : Maybe String
    }


type Msg
    = TodoListMsg TodoList.Msg
    | LoginFormMsg LoginForm.Msg
    | Save String
    | DoLoad
    | Load (Maybe String)


port save : String -> Cmd msg


port load : (Maybe String -> msg) -> Sub msg


port doload : () -> Cmd msg


port remove : () -> Cmd msg


initialModel : Model
initialModel =
    { todoListModel = TodoList.initialModel
    , loginFormModel = LoginForm.initialModel
    , accessToken = Nothing
    }


init : ( Model, Cmd Msg )
init =
    ( initialModel, doload () )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        TodoListMsg todoMsg ->
            let
                ( updatedModel, cmd ) =
                    TodoList.update todoMsg model.accessToken model.todoListModel
            in
                ( { model | todoListModel = updatedModel }, Cmd.map TodoListMsg cmd )

        LoginFormMsg loginMsg ->
            let
                ( updatedModel, cmd ) =
                    LoginForm.update loginMsg model.loginFormModel
            in
                case loginMsg of
                    GetTokenCompleted result ->
                        case result of
                            Ok token ->
                                ( { model | accessToken = Just token, loginFormModel = updatedModel }, save token )

                            _ ->
                                ( { model | loginFormModel = updatedModel }, (Cmd.map LoginFormMsg cmd) )

                    ClickLogout ->
                        ( { model
                            | accessToken = Nothing
                            , loginFormModel = updatedModel
                          }
                        , remove ()
                        )

                    _ ->
                        ( { model
                            | loginFormModel = updatedModel
                            , accessToken = Nothing
                          }
                        , (Cmd.map LoginFormMsg cmd)
                        )

        Save token ->
            ( { model | accessToken = Just token }, save token )

        DoLoad ->
            ( model, doload () )

        Load maybeToken ->
            let
                oldLoginFormModel =
                    model.loginFormModel

                newLoginFormModel =
                    case maybeToken of
                        Nothing ->
                            oldLoginFormModel

                        Just _ ->
                            { oldLoginFormModel | loggedIn = True }
            in
                ( { model
                    | accessToken = maybeToken
                    , loginFormModel = newLoginFormModel
                  }
                , Cmd.none
                )


decodeFromLocalStorage : String -> Maybe String
decodeFromLocalStorage s =
    Just s


subscriptions : Model -> Sub Msg
subscriptions model =
    load Load


view : Model -> Html Msg
view model =
    div [ class "elm-app" ]
        [ Html.map TodoListMsg (TodoList.view model.todoListModel)
        , Html.map LoginFormMsg (LoginForm.view model.loginFormModel)
        ]


main : Program Never Model Msg
main =
    Html.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
