module ExampleTest exposing (..)

import Expect exposing (..)
import Test exposing (..)
import Example exposing (userDecoder)
import Json.Decode exposing (decodeString)


suite : Test
suite =
    describe "userDecoder"
        [ test "decodes a user with an age"
            (\_ -> decodeString userDecoder "{ \"name\": \"Albert\", \"age\": 24 }" |> Expect.equal (Ok { name = "Albert", age = Just 24 }))
        , test "decodes a user without an age"
            (\_ -> decodeString userDecoder "{ \"name\": \"Albert\" }" |> Expect.equal (Ok { name = "Albert", age = Nothing }))
        ]