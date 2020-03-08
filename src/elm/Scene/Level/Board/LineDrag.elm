module Scene.Level.Board.LineDrag exposing
    ( ViewModel
    , view
    )

import Board exposing (Board)
import Board.Move as Move
import Board.Tile as Tile exposing (Tile(..))
import Css.Color as Color
import Css.Style as Style
import Html exposing (Html, span)
import Level.Setting.Tile as Tile
import Pointer exposing (Pointer)
import Scene.Level.Board.Style as Board
import Scene.Level.Board.Tile.Style exposing (..)
import Svg exposing (..)
import Svg.Attributes exposing (..)
import Utils.Svg exposing (height_, width_, windowViewBox_)
import Window exposing (Window)


type alias ViewModel =
    { window : Window
    , boardSize : Board.Size
    , tileSettings : List Tile.Setting
    , board : Board
    , isDragging : Bool
    , isSeedPodMove : Bool
    , pointer : Pointer
    }


view : ViewModel -> Html msg
view model =
    if model.isDragging then
        lineDrag model

    else
        span [] []


lineDrag : ViewModel -> Html msg
lineDrag model =
    let
        window =
            model.window

        ( oY, oX ) =
            lastMoveOrigin model

        tileScale =
            Tile.scale window
    in
    svg
        [ width_ <| toFloat window.width
        , height_ <| toFloat window.height
        , windowViewBox_ window
        , class "fixed top-0 right-0 z-4 touch-disabled"
        ]
        [ line
            [ Style.svgStyle [ Style.stroke <| strokeColor model ]
            , strokeWidth <| String.fromFloat <| 6 * tileScale
            , strokeLinecap "round"
            , x1 <| String.fromFloat oX
            , y1 <| String.fromFloat oY
            , x2 <| String.fromInt model.pointer.x
            , y2 <| String.fromInt model.pointer.y
            ]
            []
        ]


strokeColor : ViewModel -> Color.Color
strokeColor model =
    if model.isSeedPodMove then
        strokeColors SeedPod

    else
        Board.activeMoveType model.board
            |> Maybe.map strokeColors
            |> Maybe.withDefault Color.greyYellow


lastMoveOrigin : ViewModel -> ( Float, Float )
lastMoveOrigin model =
    let
        window =
            model.window

        tileScale =
            Tile.scale window

        lastMove =
            Board.lastMove model.board

        y1 =
            toFloat <| Move.y lastMove

        x1 =
            toFloat <| Move.x lastMove

        sY =
            Tile.baseSizeY * tileScale

        sX =
            Tile.baseSizeX * tileScale

        offsetY =
            Board.offsetTop (boardViewModel model) |> toFloat

        offsetX =
            (window.width - Board.width (boardViewModel model)) // 2 |> toFloat
    in
    ( ((y1 + 1) * sY) + offsetY - (sY / 2)
    , ((x1 + 1) * sX) + offsetX - (sX / 2) + 1
    )


boardViewModel : ViewModel -> Board.ViewModel
boardViewModel model =
    { window = model.window
    , boardSize = model.boardSize
    }