module Commands exposing (..)

import Date exposing (Date, fromString, toTime)
import Http
import Json.Encode as Encode
import Json.Decode exposing (Decoder, string, map3, field, at, list, succeed, fail, andThen)
import Messages exposing (TodoListMsg(..), LoginMsg(..), Msg(..))
import Models exposing (Todo, AccessToken, Login, AddTodo)


decodeTodo : Decoder Todo
decodeTodo =
    let
        decodeDate : String -> Decoder Date
        decodeDate dateString =
            case (Date.fromString dateString) of
                Ok date ->
                    succeed date

                Err err ->
                    fail err
    in
        map3 Todo
            (field "title" string)
            (field "description" string)
            (field "created_at" (string |> andThen decodeDate))


fetchTodosCmd : AccessToken -> List Todo -> Cmd TodoListMsg
fetchTodosCmd token todoList =
    let
        decodeTodoFetch : Decoder (List Todo)
        decodeTodoFetch =
            at [ "data" ] (list decodeTodo)

        request : Http.Request (List Todo)
        request =
            { method = "GET"
            , headers = [ Http.header "Authorization" ("Bearer " ++ token) ]
            , body = Http.emptyBody
            , url = "/api/todos"
            , expect = Http.expectJson decodeTodoFetch
            , timeout = Nothing
            , withCredentials = False
            }
                |> Http.request
    in
        Http.send FetchCompleted request


submitLoginCmd : Login -> Cmd LoginMsg
submitLoginCmd model =
    let
        loginRequestEncoder : Login -> Encode.Value
        loginRequestEncoder model =
            Encode.object
                [ ( "email", Encode.string model.email )
                , ( "password", Encode.string model.password )
                ]

        body : Http.Body
        body =
            model
                |> loginRequestEncoder
                |> Http.jsonBody

        request =
            Http.post "/api/auth/login" body (field "access_token" string)
    in
        Http.send GetTokenCompleted request


createTodoCmd : AccessToken -> AddTodo -> Cmd TodoListMsg
createTodoCmd token addTodo =
    let
        encoder : AddTodo -> Encode.Value
        encoder model =
            Encode.object
                [ ( "todo"
                  , Encode.object
                        [ ( "title", Encode.string model.title )
                        , ( "description", Encode.string model.description )
                        ]
                  )
                ]

        request : Http.Request Todo
        request =
            Http.request
                { method = "POST"
                , headers = [ Http.header "Authorization" ("Bearer " ++ token) ]
                , body =
                    addTodo
                        |> encoder
                        |> Http.jsonBody
                , url = "/api/todos"
                , expect = Http.expectJson decodeTodo
                , timeout = Nothing
                , withCredentials = False
                }
    in
        Http.send TodoCreated request
