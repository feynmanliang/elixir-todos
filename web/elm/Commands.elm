module Commands exposing (..)

import Date exposing (Date, fromString, toTime)
import Http
import Json.Encode as Encode
import Json.Decode exposing (Decoder, string, map3, field, at, list, succeed, fail, andThen)
import Messages exposing (TodoListMsg(..), LoginMsg(..))
import Models exposing (Todo, AccessToken, Login)


fetchTodosCmd : AccessToken -> List Todo -> Cmd TodoListMsg
fetchTodosCmd token todoList =
    let
        decodeDate : String -> Decoder Date
        decodeDate dateString =
            case (Date.fromString dateString) of
                Ok date ->
                    succeed date

                Err err ->
                    fail err

        decodeTodoData : Decoder Todo
        decodeTodoData =
            map3 Todo
                (field "title" string)
                (field "description" string)
                (field "created_at" (string |> andThen decodeDate))

        decodeTodoFetch : Decoder (List Todo)
        decodeTodoFetch =
            at [ "data" ] (list decodeTodoData)

        fetchTodos : AccessToken -> List Todo -> Http.Request (List Todo)
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
    in
        Http.send FetchCompleted (fetchTodos token todoList)


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
