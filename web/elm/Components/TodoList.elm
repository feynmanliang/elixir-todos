module Components.TodoList exposing (..)

import Html exposing (Html, text, ul, li, div, h2, button)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)
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


initialModel : Model
initialModel =
    { todos = [] }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        Fetch ->
            ( todos, Cmd.none )


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
        , button [ onClick Fetch, class "btn btn-primary" ] [ text "Fetch Articles" ]
        , ul []
            (renderTodos model)
        ]
