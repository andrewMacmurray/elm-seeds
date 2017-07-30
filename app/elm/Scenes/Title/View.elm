module Scenes.Title.View exposing (..)

import Data.Color exposing (darkYellow)
import Helpers.Style exposing (color, widthStyle)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Model exposing (..)
import Views.Seed.Circle exposing (foxglove)
import Views.Seed.Mono exposing (rose)
import Views.Seed.Twin exposing (lupin, marigold, sunflower)


title : model -> Html Msg
title model =
    div [ class "relative z-5 tc" ]
        [ div
            [ class "mt5"
            , onClick <| Transition True
            ]
            [ div
                [ style [ widthStyle 300 ]
                , class "flex center"
                ]
                [ foxglove
                , lupin
                , sunflower
                , marigold
                , rose
                ]
            ]
        , p
            [ class "f3 tracked-mega"
            , style [ color darkYellow ]
            ]
            [ text "seeds" ]
        ]