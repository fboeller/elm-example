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

type Loading a
    = Loaded a
    | Loading
    | Error Http.Error

userDecoder : Decoder User
userDecoder =
    map2 User
        (field "name" string)
        (maybe (field "age" int))

type alias Model = 
    { key : Nav.Key
    , url : Url.Url
    , loadingUser: Loading User
    }

init : () -> Url.Url -> Nav.Key -> (Model, Cmd Msg)
init _ url key = ({ key = key, url = url, loadingUser = Loading }, getUser)

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
    { model | loadingUser = 
        case model.loadingUser of 
            Loaded user -> Loaded (newUser user) 
            loadingUser -> loadingUser 
    }

gotUser : Result Http.Error User -> Model -> Model
gotUser result model = 
    { model | loadingUser = 
        case result of
            Ok user -> Loaded user
            Err error -> Error error
    }

view : Model -> Browser.Document Msg
view model = 
    { title = Url.toString model.url
    , body = [Element.layout [] (viewBody model)]
    }

viewBody : Model -> Element Msg
viewBody model =
    row [ centerY, centerX, spacing 24 ] 
        [ viewLoadingUser model.loadingUser
        , Input.button [] 
            { onPress = Just Increment
            , label = text "+" 
            }
        ]

viewLoadingUser : Loading User -> Element Msg
viewLoadingUser loadingUser =
    case loadingUser of
        Loaded user -> 
            viewUser user
        Loading -> 
            text "Loading..."
        Error _ ->
            text "Error!"

viewUser : User -> Element Msg
viewUser user =
    row [ spacing 24 ]
        [ text user.name 
        , user.age
            |> Maybe.map String.fromInt
            |> Maybe.withDefault "" 
            |> text
        ]