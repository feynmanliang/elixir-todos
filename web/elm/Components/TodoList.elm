module Components.TodoList exposing (..)

import Html exposing (Html, text, ul, li, div, h2, button)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)
import Http
import Json.Decode exposing (Decoder, string, map4, field, at, list)
import Todo


type alias Model =
    { todos : List Todo.Model }


todos : Model
todos =
    { todos =
        [ { title = "Todo 1"
          , description = "Description for todo 1"
          , ownedBy = "owner for todo 1"
          , createdOn = "12/28/2017"
          }
        , { title = "Todo 2"
          , description = "Description for todo 2"
          , ownedBy = "owner for todo 2"
          , createdOn = "12/28/2017"
          }
        , { title = "Todo 3"
          , description = "Description for todo 3"
          , ownedBy = "owner for todo 3"
          , createdOn = "12/28/2017"
          }
        ]
    }


type Msg
    = NoOp
    | Fetch
    | FetchCompleted (Result Http.Error (List Todo.Model))


initialModel : Model
initialModel =
    { todos = [] }


update : Msg -> Maybe String -> Model -> ( Model, Cmd Msg )
update msg maybeToken model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        Fetch ->
            case maybeToken of
                Nothing ->
                    ( model, Cmd.none )

                Just token ->
                    ( model, fetchTodosCmd token model )

        FetchCompleted result ->
            fetchCompleted model result


fetchTodosCmd : String -> Model -> Cmd Msg
fetchTodosCmd token model =
    Http.send FetchCompleted (fetchTodos token model)


fetchTodos : String -> Model -> Http.Request (List Todo.Model)
fetchTodos token model =
    { method = "GET"
    , headers = [ Http.header "Authorization" ("Bearer " ++ token) ]
    , body = Http.emptyBody
    , url = "/api/todos"
    , expect = Http.expectJson decodeTodoFetch
    , timeout = Nothing
    , withCredentials = False
    }
        |> Http.request


fetchCompleted : Model -> Result Http.Error (List Todo.Model) -> ( Model, Cmd Msg )
fetchCompleted model result =
    case result of
        Ok newTodos ->
            ( { model | todos = newTodos }, Cmd.none )

        Err _ ->
            ( model, Cmd.none )


decodeTodoFetch : Decoder (List Todo.Model)
decodeTodoFetch =
    let
        decodeTodoData : Decoder Todo.Model
        decodeTodoData =
            map4 Todo.Model
                (field "title" string)
                (field "description" string)
                (field "owner_id" string)
                (field "created_at" string)
    in
        list decodeTodoData


renderTodo : Todo.Model -> Html a
renderTodo todo =
    li [] [ Todo.view todo ]


renderTodos : Model -> List (Html a)
renderTodos model =
    List.map renderTodo model.todos


view : Model -> Html Msg
view model =
    div [ class "todo-list" ]
        [ h2 [] [ text "Todo List" ]
        , button [ onClick Fetch, class "btn btn-primary" ] [ text "Fetch Todos" ]
        , ul []
            (renderTodos model)
        ]
