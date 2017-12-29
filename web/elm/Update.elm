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
    let
        setLoggedIn : Login -> Bool -> Login
        setLoggedIn model newLoggedIn =
            { model | loggedIn = newLoggedIn }

        issuedJwtCompleted : Login -> Result Http.Error String -> ( Login, Cmd LoginMsg )
        issuedJwtCompleted model result =
            case result of
                Ok _ ->
                    ( setLoggedIn model True, Cmd.none )

                Err error ->
                    ( model, Cmd.none )
    in
        case msg of
            ClickSubmit ->
                ( model, submitLoginCmd model )

            ClickLogout ->
                ( setLoggedIn model False, Cmd.none )

            SetEmail email ->
                ( { model | email = email }, Cmd.none )

            SetPassword password ->
                ( { model | password = password }, Cmd.none )

            GetTokenCompleted result ->
                issuedJwtCompleted model result


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        TodoListMsg todoMsg ->
            let
                ( updatedModel, cmd ) =
                    updateTodoList todoMsg model.accessToken model.todoList
            in
                ( { model | todoList = updatedModel }, Cmd.map TodoListMsg cmd )

        LoginMsg loginMsg ->
            let
                ( updatedModel, cmd ) =
                    updateLogin loginMsg model.login
            in
                case loginMsg of
                    GetTokenCompleted result ->
                        case result of
                            Ok token ->
                                ( { model | accessToken = Just token, login = updatedModel }, Cmd.none )

                            _ ->
                                ( { model | login = updatedModel }, (Cmd.map LoginMsg cmd) )

                    ClickLogout ->
                        ( { model
                            | accessToken = Nothing
                            , login = updatedModel
                          }
                        , TokenStorage.remove ()
                        )

                    _ ->
                        ( { model
                            | login = updatedModel
                            , accessToken = Nothing
                          }
                        , (Cmd.map LoginMsg cmd)
                        )

        Save token ->
            ( { model | accessToken = Just token }, TokenStorage.save token )

        DoLoad ->
            ( model, TokenStorage.doload () )

        Load maybeToken ->
            let
                oldLoginFormModel =
                    model.login

                newLoginFormModel =
                    case maybeToken of
                        Nothing ->
                            oldLoginFormModel

                        Just _ ->
                            { oldLoginFormModel | loggedIn = True }
            in
                ( { model
                    | accessToken = maybeToken
                    , login = newLoginFormModel
                  }
                , Cmd.none
                )
