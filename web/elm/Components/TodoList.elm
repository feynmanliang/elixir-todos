module Components.TodoList exposing (..)

import Date exposing (Date, fromString)
import Html exposing (Html, text, ul, li, div, h2, button)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)
import Http
import Json.Decode exposing (Decoder, string, map3, field, at, list, succeed, fail, andThen)
import Todo


type Msg
    = NoOp
    | Fetch
    | FetchCompleted (Result Http.Error (List Todo.Model))


type alias AccessToken =
    String


initialModel : List Todo.Model
initialModel =
    []


update : Msg -> Maybe AccessToken -> List Todo.Model -> ( List Todo.Model, Cmd Msg )
update msg maybeToken todoList =
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


fetchTodosCmd : String -> List Todo.Model -> Cmd Msg
fetchTodosCmd token todoList =
    Http.send FetchCompleted (fetchTodos token todoList)


fetchTodos : String -> List Todo.Model -> Http.Request (List Todo.Model)
fetchTodos token todoList =
    { method = "GET"
    , headers = [ Http.header "Authorization" ("Bearer " ++ token) ]
    , body = Http.emptyBody
    , url = "/api/todos"
    , expect = Http.expectJson decodeTodoFetch
    , timeout = Nothing
    , withCredentials = False
    }
        |> Http.request


fetchCompleted : List Todo.Model -> Result Http.Error (List Todo.Model) -> ( List Todo.Model, Cmd Msg )
fetchCompleted todos result =
    case result of
        Ok newTodos ->
            ( newTodos, Cmd.none )

        Err _ ->
            ( todos, Cmd.none )


decodeTodoFetch : Decoder (List Todo.Model)
decodeTodoFetch =
    let
        decodeDate : String -> Decoder Date
        decodeDate dateString =
            case (Date.fromString dateString) of
                Ok date ->
                    succeed date

                Err err ->
                    fail err

        decodeTodoData : Decoder Todo.Model
        decodeTodoData =
            map3 Todo.Model
                (field "title" string)
                (field "description" string)
                (field "created_at" (string |> andThen decodeDate))
    in
        at [ "data" ] (list decodeTodoData)


renderTodo : Todo.Model -> Html a
renderTodo todo =
    li [] [ Todo.view todo ]


renderTodos : List Todo.Model -> List (Html a)
renderTodos todoList =
    List.map renderTodo todoList


view : List Todo.Model -> Html Msg
view todoList =
    div [ class "todo-list" ]
        [ h2 [] [ text "Todo List" ]
        , button [ onClick Fetch, class "btn btn-primary" ] [ text "Fetch Todos" ]
        , ul []
            (renderTodos todoList)
        ]
