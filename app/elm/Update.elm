module Update exposing (..)

import Data.Board.Entering exposing (handleAddNewTiles, handleResetEntering, makeNewTiles)
import Data.Board.Falling exposing (handleFallingTiles, handleResetFallingTiles)
import Data.Board.Leaving exposing (handleLeavingTiles, handleRemoveLeavingTiles)
import Data.Board.Make exposing (handleGenerateTiles, handleMakeBoard)
import Data.Board.Shift exposing (handleShiftBoard, shiftBoard)
import Data.Moves.Check exposing (handleCheckMove, handleStartMove, handleStopMove)
import Delay
import Dict
import Model exposing (..)


init : ( Model, Cmd Msg )
init =
    initialState ! [ handleGenerateTiles initialState ]


initialState : Model
initialState =
    { board = Dict.empty
    , isDragging = False
    , currentMove = []
    , boardSettings = { sizeY = 8, sizeX = 8 }
    , tileSettings = { sizeY = 51, sizeX = 55 }
    }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        InitTiles tiles ->
            (model |> handleMakeBoard tiles) ! []

        AddTiles tiles ->
            (model |> handleAddNewTiles tiles) ! []

        StopMove ->
            model
                ! [ Delay.start StopMoveSequence
                        [ ( 0, SetLeavingTiles )
                        , ( 0, ResetMove )
                        , ( 500, SetFallingTiles )
                        , ( 500, ShiftBoard )
                        , ( 500, MakeNewTiles )
                        , ( 500, ResetEntering )
                        ]
                  ]

        SetLeavingTiles ->
            (model |> handleLeavingTiles) ! []

        SetFallingTiles ->
            (model |> handleFallingTiles) ! []

        ShiftBoard ->
            (model
                |> handleShiftBoard
                |> handleResetFallingTiles
                |> handleRemoveLeavingTiles
            )
                ! []

        MakeNewTiles ->
            model ! [ makeNewTiles model.board ]

        ResetEntering ->
            (model |> handleResetEntering) ! []

        ResetMove ->
            (model |> handleStopMove) ! []

        StopMoveSequence msgs ->
            Delay.handleSequence StopMoveSequence msgs update model

        StartMove move ->
            (model |> handleStartMove move) ! []

        CheckMove move ->
            (model |> handleCheckMove move) ! []