module Components.LoginForm exposing (..)

import Debug exposing (..)
import Html exposing (Html, text, div, input, button)
import Html.Attributes exposing (type_, placeholder)
import Html.Events exposing (onInput, onClick)
import Http
import Json.Decode as Decode
import Json.Encode as Encode


type alias Model =
    { email : String
    , password : String
    , jwt : String
    }


type Msg
    = ClickSubmit
    | ClickLogout
    | SetEmail String
    | SetPassword String
    | GetTokenCompleted (Result Http.Error String)


initialModel : Model
initialModel =
    { email = ""
    , password = ""
    , jwt = ""
    }


loginRequestEncoder : Model -> Encode.Value
loginRequestEncoder model =
    Encode.object
        [ ( "email", Encode.string model.email )
        , ( "password", Encode.string model.password )
        ]


submitLogin : Model -> Cmd Msg
submitLogin model =
    let
        body =
            model
                |> loginRequestEncoder
                |> Http.jsonBody

        request =
            Http.post "/api/auth/login" body (Decode.field "access_token" Decode.string)
    in
        Http.send GetTokenCompleted request


issuedJwtCompleted : Model -> Result Http.Error String -> ( Model, Cmd Msg )
issuedJwtCompleted model result =
    case result of
        Ok token ->
            ( { model | jwt = token }, Cmd.none )

        Err error ->
            ( model, Cmd.none )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ClickSubmit ->
            ( model, submitLogin model )

        ClickLogout ->
            ( { model | jwt = "" }, Cmd.none )

        SetEmail email ->
            ( { model | email = email }, Cmd.none )

        SetPassword password ->
            ( { model | password = password }, Cmd.none )

        GetTokenCompleted result ->
            issuedJwtCompleted model result


view : Model -> Html Msg
view model =
    let
        loggedIn : Bool
        loggedIn =
            if String.length model.jwt > 0 then
                True
            else
                False
    in
        if loggedIn then
            div [] [ button [ onClick ClickLogout ] [ text "Logout" ] ]
        else
            div []
                [ input [ type_ "text", placeholder "Email", onInput SetEmail ] []
                , input [ type_ "password", placeholder "Password", onInput SetPassword ] []
                , button [ onClick ClickSubmit ] [ text "Submit" ]
                ]
