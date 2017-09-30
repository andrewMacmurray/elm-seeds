module Views.Level.Board exposing (..)

import Data.Level.Board.Tile exposing (growingOrder, isLeaving, leavingOrder, tileColorMap, tileSizeMap)
import Dict
import Helpers.Html exposing (emptyProperty, onMouseDownPreventDefault)
import Helpers.Style exposing (..)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onMouseEnter, onMouseUp)
import Scenes.Level.Types exposing (..)
import Scenes.Level.Types as Level exposing (..)
import Views.Level.Line exposing (renderLine)
import Views.Level.Styles exposing (..)


board : Level.Model -> Html Level.Msg
board model =
    boardLayout model
        [ div [ class "relative z-5" ] <| renderTiles model
        , div [ class "absolute top-0 left-0 z-0" ] <| renderLines model
        ]


renderTiles : Level.Model -> List (Html Level.Msg)
renderTiles model =
    model.board
        |> Dict.toList
        |> List.map (renderTile model)


renderLines : Level.Model -> List (Html Level.Msg)
renderLines model =
    model.board
        |> Dict.toList
        |> List.map (renderLineLayer model)


boardLayout : Level.Model -> List (Html Level.Msg) -> Html Level.Msg
boardLayout model =
    div
        [ class "relative z-3 center flex flex-wrap"
        , style
            [ widthStyle <| boardWidth model
            , boardMarginTop model
            ]
        ]


renderLineLayer : Level.Model -> Move -> Html Level.Msg
renderLineLayer model (( ( y, x ) as coord, tile ) as move) =
    div
        [ style <|
            styles
                [ tileWidthHeightStyles model
                , tileCoordsStyles model coord
                ]
        , class "dib absolute touch-disabled"
        ]
        [ renderLine model move
        ]


renderTile : Level.Model -> Move -> Html Level.Msg
renderTile model (( ( y, x ) as coord, tile ) as move) =
    div
        [ style <|
            styles
                [ tileWidthHeightStyles model
                , tileCoordsStyles model coord
                , leavingStyles model move
                ]
        , class "dib absolute pointer"
        , hanldeMoveEvents model move
        ]
        [ innerTile model move
        , tracer model move
        , wall move
        ]


handleStop : Level.Model -> Attribute Level.Msg
handleStop model =
    if model.isDragging && model.moveShape /= Just Square then
        onMouseUp <| StopMove Line
    else
        emptyProperty


hanldeMoveEvents : Level.Model -> Move -> Attribute Level.Msg
hanldeMoveEvents model move =
    if model.isDragging then
        onMouseEnter <| CheckMove move
    else
        onMouseDownPreventDefault <| StartMove move


tracer : Level.Model -> Move -> Html Level.Msg
tracer model move =
    let
        extraStyles =
            moveTracerStyles model move
    in
        makeInnerTile extraStyles model move


wall : Move -> Html Level.Msg
wall move =
    div
        [ style <| wallStyles move
        , class centerBlock
        ]
        []


innerTile : Level.Model -> Move -> Html Level.Msg
innerTile model move =
    let
        extraStyles =
            draggingStyles model move
    in
        makeInnerTile extraStyles model move


makeInnerTile : List Style -> Level.Model -> Move -> Html Level.Msg
makeInnerTile extraStyles model (( _, tile ) as move) =
    div
        [ class <| baseTileClasses tile
        , style <|
            styles
                [ extraStyles
                , baseTileStyles model move
                , [ ( "will-change", "transform, opacity" ) ]
                ]
        ]
        []


baseTileStyles : Level.Model -> Move -> List Style
baseTileStyles model (( _, tile ) as move) =
    styles
        [ growingStyles move
        , enteringStyles move
        , fallingStyles move
        , tileSizeMap tile
        , tileColorMap model.seedType tile
        ]


baseTileClasses : Block -> String
baseTileClasses tile =
    classes
        [ "br-100"
        , centerBlock
        ]
