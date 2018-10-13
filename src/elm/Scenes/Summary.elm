module Scenes.Summary exposing (view)

import Config.Levels exposing (allLevels)
import Css.Animation exposing (animation, delay, linear)
import Css.Color exposing (gold, rainBlue, washedYellow)
import Css.Style as Style exposing (..)
import Css.Transform exposing (translateX, translateY)
import Data.Board.Types exposing (..)
import Data.Level.Summary exposing (..)
import Data.Level.Types exposing (Progress)
import Data.Wave exposing (wave)
import Html exposing (..)
import Html.Attributes exposing (class)
import Shared
import Types exposing (..)
import Views.Icons.RainBank exposing (..)
import Views.Icons.SeedBank exposing (seedBank)
import Views.Icons.SunBank exposing (sunBank, sunBankFull)
import Views.Seed.All exposing (renderSeed)


view : Shared.Data -> Html Msg
view ({ progress, currentLevel } as model) =
    let
        primarySeed =
            primarySeedType allLevels progress currentLevel |> Maybe.withDefault Sunflower

        resources =
            secondaryResourceTypes allLevels currentLevel |> Maybe.withDefault []
    in
    div
        [ style
            [ height <| toFloat model.window.height
            , background washedYellow
            , animation "fade-in" 1000 [ linear ]
            ]
        , class "fixed z-5 flex justify-center items-center w-100 top-0 left-0"
        ]
        [ div [ style [ marginTop -100 ] ]
            [ div
                [ style
                    [ width 65
                    , marginBottom 30
                    ]
                , class "center"
                ]
                [ seedBank primarySeed <| percentComplete allLevels (Seed primarySeed) progress currentLevel ]
            , div [ style [ height 50 ] ] <| List.map (renderResourceBank progress currentLevel) resources
            ]
        ]


renderResourceBank : Progress -> Maybe Progress -> TileType -> Html msg
renderResourceBank progress currentLevel tileType =
    let
        fillLevel =
            percentComplete allLevels tileType progress currentLevel
    in
    case tileType of
        Rain ->
            div [ style [ width 40 ], class "dib ph1 mh4" ]
                [ renderResourceFill tileType
                , rainBank fillLevel
                ]

        Sun ->
            div [ style [ width 40 ], class "dib mh4" ]
                [ renderResourceFill tileType
                , sunBank fillLevel
                ]

        Seed seedType ->
            div [ style [ width 40 ], class "dib ph1 mh4" ]
                [ renderResourceFill tileType
                , seedBank seedType fillLevel
                ]

        _ ->
            span [] []


renderResourceFill : TileType -> Html msg
renderResourceFill tileType =
    case tileType of
        Rain ->
            div [ style [ height 50 ] ]
                [ div [ style [ width 13 ], class "center" ] [ rainBankFull ]
                , div [ class "relative" ] <| List.map (drop rainBlue) <| List.range 1 50
                ]

        Sun ->
            div [ style [ height 50 ] ]
                [ div [ style [ width 18 ], class "center" ] [ sunBankFull ]
                , div [ class "relative" ] <| List.map (drop gold) <| List.range 4 54
                ]

        Seed seedType ->
            div [ style [ height 50 ] ]
                [ div [ style [ width 15 ], class "center" ] [ renderSeed seedType ]
                , div [ class "relative", style [ transform [ translateY -10 ] ] ] <| List.map (seedDrop seedType) <| List.range 7 57
                ]

        _ ->
            span [] []


seedDrop : SeedType -> Int -> Html msg
seedDrop seedType n =
    let
        d =
            if modBy 3 n == 0 then
                30

            else if modBy 3 n == 1 then
                60

            else
                90
    in
    div
        [ style
            [ transform
                [ translateX <|
                    wave
                        { left = -5
                        , center = 0
                        , right = 5
                        }
                        (n - 1)
                ]
            ]
        ]
        [ div
            [ style
                [ width 5
                , height 8
                , opacity 0
                , animation "fade-slide-down" 150 [ delay <| n * d, linear ]
                ]
            , class "absolute top-0 left-0 right-0 center"
            ]
            [ renderSeed seedType ]
        ]


drop : String -> Int -> Html msg
drop bgColor n =
    let
        d =
            if modBy 3 n == 0 then
                30

            else if modBy 3 n == 1 then
                60

            else
                90
    in
    div
        [ style
            [ transform
                [ translateX <|
                    wave
                        { left = -5
                        , center = 0
                        , right = 5
                        }
                        (n - 1)
                ]
            ]
        ]
        [ div
            [ style
                [ width 6
                , height 6
                , background bgColor
                , opacity 0
                , animation "fade-slide-down" 150 [ delay (n * d), linear ]
                ]
            , class "br-100 absolute left-0 right-0 center"
            ]
            []
        ]
