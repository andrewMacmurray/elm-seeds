module Views.Board.Line exposing (renderLine)

import Css.Style as Style exposing (Style, marginAuto, styles)
import Css.Transform exposing (..)
import Data.Board.Block exposing (getTileState)
import Data.Board.Move as Move exposing (Move)
import Data.Board.Tile as Tile exposing (Bearing(..), State(..))
import Data.Window exposing (Window)
import Html exposing (Html, div, span)
import Svg exposing (..)
import Svg.Attributes exposing (..)
import Views.Board.Tile.Styles exposing (strokeColors, tileCoordsStyles, tileWidthheights)


renderLine : Window -> Move -> Html msg
renderLine window move =
    div
        [ styles
            [ tileWidthheights window
            , tileCoordsStyles window <| Move.coord move
            ]
        , class "dib absolute touch-disabled"
        ]
        [ lineFromMove window move ]


lineFromMove : Window -> Move -> Html msg
lineFromMove window move =
    let
        tileState =
            getTileState <| Move.block move
    in
    case tileState of
        Dragging tileType _ Left ->
            innerLine window tileType Left

        Dragging tileType _ Right ->
            innerLine window tileType Right

        Dragging tileType _ Up ->
            innerLine window tileType Up

        Dragging tileType _ Down ->
            innerLine window tileType Down

        _ ->
            span [] []


innerLine : Window -> Tile.Type -> Bearing -> Html msg
innerLine window tileType bearing =
    let
        tileScale =
            Tile.scale window
    in
    svg
        [ width <| String.fromFloat <| 50 * tileScale
        , height <| String.fromFloat <| 9 * tileScale
        , Style.svgStyle
            [ marginAuto
            , lineTransforms window bearing
            ]
        , class "absolute bottom-0 right-0 left-0 top-0 z-0"
        ]
        [ line
            [ strokeWidth <| String.fromFloat <| 11 * tileScale
            , x1 "0"
            , y1 "0"
            , x2 <| String.fromFloat <| 50 * tileScale
            , y2 "0"
            , Style.svgStyle [ Style.stroke <| strokeColors tileType ]
            ]
            []
        ]


lineTransforms : Window -> Bearing -> Style
lineTransforms window bearing =
    let
        xOffset =
            Tile.scale window * 25
    in
    case bearing of
        Left ->
            Style.transform [ translate -xOffset 1.5 ]

        Right ->
            Style.transform [ translate xOffset 1.5 ]

        Up ->
            Style.transform [ rotateZ 90, translate -xOffset 1.5 ]

        Down ->
            Style.transform [ rotateZ 90, translate xOffset 1.5 ]

        _ ->
            Style.none
