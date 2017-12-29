module Update exposing (..)

import Commands
    exposing
        ( fetchTodosCmd
        , submitLoginCmd
        , createTodoCmd
        )
import Messages
    exposing
        ( TodoListMsg(..)
        , LoginMsg(..)
        , AddTodoMsg(..)
        , Msg(..)
        )
import Models exposing (Todo, AccessToken, Login, AddTodo, Model)
import TokenStorage


updateTodoList : TodoListMsg -> Maybe AccessToken -> List Todo -> ( List Todo, Cmd TodoListMsg )
updateTodoList msg maybeToken todoList =
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
            case result of
                Ok newTodos ->
                    ( newTodos, Cmd.none )

                Err _ ->
                    ( todoList, Cmd.none )

        TodoCreated result ->
            case result of
                Ok newTodo ->
                    ( newTodo :: todoList, Cmd.none )

                Err _ ->
                    ( todoList, Cmd.none )


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


updateAddTodo : Maybe AccessToken -> AddTodoMsg -> AddTodo -> ( AddTodo, Cmd Msg )
updateAddTodo maybeToken msg addTodo =
    case msg of
        SetTitle title ->
            ( { addTodo | title = title }, Cmd.none )

        SetDescription description ->
            ( { addTodo | description = description }, Cmd.none )

        ClickSubmitTodo ->
            case maybeToken of
                Nothing ->
                    ( addTodo, Cmd.none )

                Just token ->
                    ( { addTodo | title = "", description = "" }, Cmd.map TodoListMsg (createTodoCmd token addTodo) )


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

        AddTodoMsg addTodoMsg ->
            let
                ( updatedModel, cmd ) =
                    updateAddTodo model.login.accessToken addTodoMsg model.addTodo
            in
                ( { model | addTodo = updatedModel }, cmd )
