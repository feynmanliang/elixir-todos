module View exposing (..)

import Date exposing (toTime)
import Html exposing (Html, span, strong, em, a, text, li, div, h2, button, ul, input, form)
import Html.Attributes exposing (class, type_, placeholder, name, value)
import Html.Events exposing (onClick, onInput)
import Messages exposing (TodoListMsg(..), LoginMsg(..), AddTodoMsg(..), Msg(..))
import Models exposing (Todo, Login, Model, AddTodo)


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


viewAddTodo : Login -> AddTodo -> Html AddTodoMsg
viewAddTodo login addTodo =
    case login.accessToken of
        Nothing ->
            div [] []

        Just _ ->
            div []
                [ input [ type_ "text", placeholder "Title", onInput SetTitle ] []
                , input [ type_ "text", placeholder "Description", onInput SetDescription ] []
                , button [ onClick ClickSubmitTodo ] [ text "Submit" ]
                ]


renderLogin : Login -> Html LoginMsg
renderLogin model =
    case model.accessToken of
        Just _ ->
            div [] [ button [ onClick ClickLogout ] [ text "Logout" ] ]

        Nothing ->
            div []
                [ input [ type_ "text", placeholder "Email", onInput SetEmail ] []
                , input [ type_ "password", placeholder "Password", onInput SetPassword ] []
                , button [ onClick ClickSubmit ] [ text "Submit" ]
                ]


view : Model -> Html Msg
view model =
    div [ class "elm-app" ]
        [ Html.map TodoListMsg (renderTodoList model.todoList)
        , Html.map AddTodoMsg (viewAddTodo model.login model.addTodo)
        , Html.map LoginMsg (renderLogin model.login)
        ]
