module Main exposing (..)

import Browser
import Browser.Navigation as Nav
import Json.Decode exposing (Decoder, field, int, string, map2, maybe)
import Http
import Url
import Element exposing (..)
import Element.Input as Input

main : Program () Model Msg
main =
  Browser.application
    { init = init
    , view = view
    , update = update
    , subscriptions = subscriptions
    , onUrlChange = UrlChanged
    , onUrlRequest = LinkClicked
    }


type alias User = 
    { name: String
    , age: Maybe Int
    }

userDecoder : Decoder User
userDecoder =
    map2 User
        (field "name" string)
        (maybe (field "age" int))

type alias Model = 
    { key : Nav.Key
    , url : Url.Url
    , user: Maybe User
    , error: Maybe String
    }

init : () -> Url.Url -> Nav.Key -> (Model, Cmd Msg)
init _ url key = ({ key = key, url = url, user = Nothing, error = Nothing }, getUser)

getUser : Cmd Msg
getUser = Http.get 
    { url = "http://localhost:4200/user"
    , expect = Http.expectJson GotUser userDecoder 
    }

subscriptions : Model -> Sub Msg
subscriptions _ =
  Sub.none

type Msg 
  = LinkClicked Browser.UrlRequest
  | UrlChanged Url.Url
  | Increment
  | GotUser (Result Http.Error User)

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        LinkClicked urlRequest ->
            case urlRequest of
                Browser.Internal url ->
                    (model, Nav.pushUrl model.key (Url.toString url))
                Browser.External href ->
                    (model, Nav.load href)
        UrlChanged url ->
            ({ model | url = url }, Cmd.none)
        Increment -> (increment model, Cmd.none)
        GotUser result -> (gotUser result model, Cmd.none)

increment : Model -> Model
increment model = 
    let newUser user = { user | age = Maybe.map ((+) 1) user.age } in
    { model | user = Maybe.map newUser model.user }

gotUser : Result Http.Error User -> Model -> Model
gotUser result model = 
    case result of
        Ok user -> { model | user = Just user, error = Nothing }
        Err error -> { model | error = Nothing, user = Nothing } 

view : Model -> Browser.Document Msg
view model = 
    { title = Url.toString model.url
    , body = [Element.layout [] <| viewBody model]
    }

viewBody : Model -> Element Msg
viewBody model =
    row [ centerY, centerX, spacing 24 ] 
        [ viewError model.error
        , viewUser model.user
        , Input.button [] { onPress = Just Increment, label = text "+" }
        ]

viewError : Maybe String -> Element Msg
viewError error =
    text <| Maybe.withDefault "" error

viewUser : Maybe User -> Element Msg
viewUser user =
    text 
        <| Maybe.withDefault "" 
        <| Maybe.map String.fromInt 
        <| Maybe.andThen (.age) user