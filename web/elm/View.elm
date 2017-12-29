module View exposing (..)

import Date exposing (toTime)
import Html exposing (Html, span, strong, em, a, text, li, div, h2, button, ul, input)
import Html.Attributes exposing (class, type_, placeholder)
import Html.Events exposing (onClick, onInput)
import Messages exposing (TodoListMsg(..), LoginMsg(..), Msg(..))
import Models exposing (Todo, Login, Model)


renderTodoList : List Todo -> Html TodoListMsg
renderTodoList todoList =
    let
        sortedTodoList : List Todo
        sortedTodoList =
            List.sortBy (\todo -> todo.createdOn |> toTime) todoList

        renderTodo : Todo -> Html a
        renderTodo todo =
            span [ class "todo" ]
                [ strong [] [ text todo.title ]
                , em [] [ text (" (created on : " ++ (toString todo.createdOn) ++ ")") ]
                ]
    in
        div [ class "todo-list" ]
            [ h2 [] [ text "Todo List" ]
            , button [ onClick Fetch, class "btn btn-primary" ] [ text "Fetch Todos" ]
            , ul []
                (List.map (\todo -> li [] [ renderTodo todo ]) sortedTodoList)
            ]


renderLogin : Login -> Html LoginMsg
renderLogin model =
    if model.loggedIn then
        div [] [ button [ onClick ClickLogout ] [ text "Logout" ] ]
    else
        div []
            [ input [ type_ "text", placeholder "Email", onInput SetEmail ] []
            , input [ type_ "password", placeholder "Password", onInput SetPassword ] []
            , button [ onClick ClickSubmit ] [ text "Submit" ]
            ]


view : Model -> Html Msg
view model =
    div [ class "elm-app" ]
        [ Html.map TodoListMsg (renderTodoList model.todoList)
        , Html.map LoginMsg (renderLogin model.login)
        ]
