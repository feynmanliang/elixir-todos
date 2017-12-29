module Components.LoginForm exposing (..)

import Html exposing (Html, text, div, input, button)
import Html.Attributes exposing (type_, placeholder)
import Html.Events exposing (onInput, onClick)
import Http
import Json.Decode as Decode
import Json.Encode as Encode


type alias Model =
    { email : String
    , password : String
    , loggedIn : Bool
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
    , loggedIn = False
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
        Ok _ ->
            ( setLoggedIn model True, Cmd.none )

        Err error ->
            ( model, Cmd.none )


setLoggedIn : Model -> Bool -> Model
setLoggedIn model newLoggedIn =
    { model | loggedIn = newLoggedIn }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ClickSubmit ->
            ( model, submitLogin model )

        ClickLogout ->
            ( setLoggedIn model False, Cmd.none )

        SetEmail email ->
            ( { model | email = email }, Cmd.none )

        SetPassword password ->
            ( { model | password = password }, Cmd.none )

        GetTokenCompleted result ->
            issuedJwtCompleted model result


view : Model -> Html Msg
view model =
    if model.loggedIn then
        div [] [ button [ onClick ClickLogout ] [ text "Logout" ] ]
    else
        div []
            [ input [ type_ "text", placeholder "Email", onInput SetEmail ] []
            , input [ type_ "password", placeholder "Password", onInput SetPassword ] []
            , button [ onClick ClickSubmit ] [ text "Submit" ]
            ]
