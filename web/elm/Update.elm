module Update exposing (..)

import Http exposing (Error)
import Commands exposing (fetchTodosCmd, submitLoginCmd)
import Messages exposing (TodoListMsg(..), LoginMsg(..), Msg(..))
import Models exposing (Todo, AccessToken, Login, Model)
import TokenStorage


updateTodoList : TodoListMsg -> Maybe AccessToken -> List Todo -> ( List Todo, Cmd TodoListMsg )
updateTodoList msg maybeToken todoList =
    let
        fetchCompleted : List Todo -> Result Http.Error (List Todo) -> ( List Todo, Cmd TodoListMsg )
        fetchCompleted todos result =
            case result of
                Ok newTodos ->
                    ( newTodos, Cmd.none )

                Err _ ->
                    ( todos, Cmd.none )
    in
        case msg of
            NoOp ->
                ( todoList, Cmd.none )

            Fetch ->
                case maybeToken of
                    Nothing ->
                        ( todoList, Cmd.none )

                    Just token ->
                        ( todoList, fetchTodosCmd token todoList )

            FetchCompleted result ->
                fetchCompleted todoList result


updateLogin : LoginMsg -> Login -> ( Login, Cmd LoginMsg )
updateLogin msg model =
    case msg of
        ClickSubmit ->
            ( model, submitLoginCmd model )

        ClickLogout ->
            ( { model | accessToken = Nothing }, TokenStorage.remove () )

        SetEmail email ->
            ( { model | email = email }, Cmd.none )

        SetPassword password ->
            ( { model | password = password }, Cmd.none )

        GetTokenCompleted result ->
            case result of
                Err _ ->
                    ( model, Cmd.none )

                Ok token ->
                    ( { model | accessToken = Just token }, TokenStorage.save token )

        DoLoad ->
            ( model, TokenStorage.doload () )

        Load maybeToken ->
            case maybeToken of
                Nothing ->
                    ( model, Cmd.none )

                Just token ->
                    ( { model | accessToken = Just token }, Cmd.none )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        TodoListMsg todoMsg ->
            let
                ( updatedModel, cmd ) =
                    updateTodoList todoMsg model.login.accessToken model.todoList
            in
                ( { model | todoList = updatedModel }, Cmd.map TodoListMsg cmd )

        LoginMsg loginMsg ->
            let
                ( updatedModel, cmd ) =
                    updateLogin loginMsg model.login
            in
                ( { model | login = updatedModel }, (Cmd.map LoginMsg cmd) )
