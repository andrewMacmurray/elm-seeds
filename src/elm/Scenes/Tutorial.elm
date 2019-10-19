module Scenes.Tutorial exposing
    ( Config
    , Model
    , Msg(..)
    , Sequence
    , getContext
    , init
    , update
    , updateContext
    , view
    )

import Context exposing (Context)
import Css.Color exposing (darkYellow, greyYellow)
import Css.Style as Style exposing (..)
import Css.Transform exposing (..)
import Css.Transition exposing (delay, linear, transitionAll)
import Css.Unit exposing (pc)
import Data.Board as Board
import Data.Board.Block as Block
import Data.Board.Falling exposing (setFallingTiles)
import Data.Board.Generate exposing (insertNewEnteringTiles)
import Data.Board.Move as Move
import Data.Board.Move.Bearing as Bearing
import Data.Board.Shift exposing (shiftBoard)
import Data.Board.Tile as Tile
import Data.Board.Types exposing (..)
import Dict exposing (Dict)
import Exit exposing (continue, exit)
import Helpers.Attribute as Attribute
import Helpers.Delay exposing (pause, sequence)
import Html exposing (..)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)
import Scenes.Level.TopBar exposing (renderScoreIcon)
import Views.Board.Line exposing (renderLine)
import Views.Board.Tile as Tile
import Views.Board.Tile.Styles exposing (boardHeight, boardWidth)



-- Model


type alias Model =
    { context : Context
    , board : Board
    , boardVisible : Bool
    , textVisible : Bool
    , resourceBankVisible : Bool
    , containerVisible : Bool
    , canvasVisible : Bool
    , skipped : Bool
    , resourceBank : TileType
    , boardDimensions : BoardDimensions
    , currentText : Int
    , text : Dict Int String
    }


type alias Config =
    { text : Dict Int String
    , boardDimensions : BoardDimensions
    , board : Board
    , resourceBank : TileType
    , sequence : Sequence
    }


type alias Sequence =
    List ( Float, Msg )


type Msg
    = DragTile Coord
    | SetGrowingPods
    | SetLeaving
    | ResetLeaving
    | GrowPods SeedType
    | ResetGrowingPods
    | EnteringTiles (List TileType)
    | FallTiles
    | ShiftBoard
    | SetBoardDimensions BoardDimensions
    | HideBoard
    | ShowBoard
    | HideText
    | ShowText
    | HideResourceBank
    | ShowResourceBank
    | HideContainer
    | ShowContainer
    | HideCanvas
    | ResetBoard Board
    | NextText
    | SkipTutorial
    | DisableTutorial
    | ExitTutorial



-- Context


getContext : Model -> Context
getContext model =
    model.context


updateContext : (Context -> Context) -> Model -> Model
updateContext f model =
    { model | context = f model.context }



-- Init


init : Config -> Context -> ( Model, Cmd Msg )
init config context =
    ( loadTutorialData config <| initialState context
    , sequence <| pause 2000 config.sequence
    )


initialState : Context -> Model
initialState context =
    { context = context
    , board = Dict.empty
    , boardVisible = True
    , textVisible = True
    , resourceBankVisible = False
    , containerVisible = False
    , canvasVisible = True
    , skipped = False
    , resourceBank = Seed Sunflower
    , boardDimensions = { y = 2, x = 2 }
    , currentText = 1
    , text = Dict.empty
    }


loadTutorialData : Config -> Model -> Model
loadTutorialData config model =
    { model
        | boardDimensions = config.boardDimensions
        , board = config.board
        , text = config.text
        , resourceBank = config.resourceBank
        , currentText = 1
        , skipped = False
    }



-- Update


update : Msg -> Model -> Exit.Status ( Model, Cmd Msg )
update msg model =
    case msg of
        DragTile coord ->
            continue (handleDragTile coord model) []

        SetGrowingPods ->
            continue (updateBlocks Block.setDraggingToGrowing model) []

        SetLeaving ->
            continue (updateBlocks Block.setDraggingToLeaving model) []

        ResetLeaving ->
            continue (updateBlocks Block.setLeavingToEmpty model) []

        GrowPods seedType ->
            continue (updateBlocks (Block.growSeedPod seedType) model) []

        ResetGrowingPods ->
            continue (updateBlocks Block.setGrowingToStatic model) []

        EnteringTiles tiles ->
            continue (handleInsertEnteringTiles tiles model) []

        FallTiles ->
            continue (mapBoard setFallingTiles model) []

        ShiftBoard ->
            continue
                (model
                    |> mapBoard shiftBoard
                    |> updateBlocks Block.setFallingToStatic
                    |> updateBlocks Block.setLeavingToEmpty
                )
                []

        SetBoardDimensions n ->
            continue { model | boardDimensions = n } []

        HideBoard ->
            continue { model | boardVisible = False } []

        ShowBoard ->
            continue { model | boardVisible = True } []

        HideText ->
            continue { model | textVisible = False } []

        ShowText ->
            continue { model | textVisible = True } []

        HideResourceBank ->
            continue { model | resourceBankVisible = False } []

        ShowResourceBank ->
            continue { model | resourceBankVisible = True } []

        HideContainer ->
            continue { model | containerVisible = False } []

        ShowContainer ->
            continue { model | containerVisible = True } []

        HideCanvas ->
            continue { model | canvasVisible = False } []

        ResetBoard board ->
            continue { model | board = board } []

        NextText ->
            continue { model | currentText = model.currentText + 1 } []

        SkipTutorial ->
            continue model [ skipSequence ]

        DisableTutorial ->
            continue { model | skipped = True } []

        ExitTutorial ->
            exit model



-- Update Helpers


updateBlocks : (Block -> Block) -> Model -> Model
updateBlocks f model =
    { model | board = Board.updateBlocks f model.board }


mapBoard : (Board -> Board) -> Model -> Model
mapBoard f model =
    { model | board = f model.board }


skipSequence : Cmd Msg
skipSequence =
    sequence
        [ ( 0, HideCanvas )
        , ( 1500, ExitTutorial )
        , ( 0, DisableTutorial )
        ]


handleDragTile : Coord -> Model -> Model
handleDragTile coord model =
    let
        sunflower =
            Space <| Static <| Seed Sunflower

        tile =
            Dict.get coord model.board |> Maybe.withDefault sunflower
    in
    { model | board = Bearing.add ( coord, tile ) model.board }


handleInsertEnteringTiles : List TileType -> Model -> Model
handleInsertEnteringTiles tileList =
    mapBoard <| insertNewEnteringTiles tileList



-- View


view : Model -> Html Msg
view model =
    div
        [ class "w-100 h-100 fixed top-0 flex items-center justify-center z-5"
        , style
            [ backgroundColor "rgba(255, 252, 227, 0.98)"
            , transitionAll 1200 [ linear ]
            , showIf model.canvasVisible
            ]
        ]
        [ div
            [ style
                [ Style.property "margin-top" (pc -3)
                , transitionAll 800 [ linear ]
                , showIf model.containerVisible
                ]
            , class "tc"
            ]
            [ tutorialBoard model
            , p
                [ style
                    [ color darkYellow
                    , transitionAll 500 []
                    , showIf model.textVisible
                    ]
                ]
                [ text <| getText model.text model.currentText ]
            ]
        , p
            [ handleSkip model
            , style
                [ color greyYellow
                , bottom 30
                , transitionAll 800 [ linear, delay 800 ]
                , showIf model.containerVisible
                ]
            , class "absolute left-0 right-0 pointer tc ttu tracked-mega f6"
            ]
            [ text "skip" ]
        ]


getText : Dict Int String -> Int -> String
getText textDict n =
    Dict.get n textDict |> Maybe.withDefault ""


handleSkip : Model -> Attribute Msg
handleSkip model =
    Attribute.applyIf (not model.skipped) <| onClick SkipTutorial


tutorialBoard : Model -> Html msg
tutorialBoard model =
    let
        viewModel =
            ( model.context.window, model.boardDimensions )
    in
    div
        [ class "center relative"
        , style
            [ width <| toFloat <| boardWidth viewModel
            , height <| toFloat <| boardHeight viewModel
            , showIf model.boardVisible
            , transitionAll 500 []
            ]
        ]
        [ div [ class "absolute z-5" ] [ renderResourceBank model ]
        , div [ class "absolute z-2" ] <| renderTiles model
        , div [ class "absolute z-0" ] <| renderLines_ model
        ]


renderResourceBank : Model -> Html msg
renderResourceBank ({ context, resourceBankVisible, resourceBank } as model) =
    let
        window =
            context.window

        tileScale =
            Tile.scale window

        offsetX =
            resourceBankOffsetX model

        offsetY =
            -100
    in
    div
        [ style
            [ transitionAll 800 []
            , transform [ translate offsetX offsetY ]
            , showIf resourceBankVisible
            ]
        ]
        [ renderScoreIcon resourceBank <| Tile.baseSizeY * tileScale ]


resourceBankOffsetX : Model -> Float
resourceBankOffsetX model =
    Tile.baseSizeX
        * toFloat (model.boardDimensions.x - 1)
        * Tile.scale model.context.window
        / 2


renderLines_ : Model -> List (Html msg)
renderLines_ model =
    model.board
        |> Dict.toList
        |> List.map (fadeLine model)


fadeLine : Model -> Move -> Html msg
fadeLine model (( _, tile ) as move) =
    let
        visible =
            Block.hasLine tile
    in
    div
        [ style [ transitionAll 500 [], showIf visible ] ]
        [ renderLine model.context.window move ]


renderTiles : Model -> List (Html msg)
renderTiles model =
    model.board
        |> Dict.toList
        |> List.map
            (\move ->
                Tile.view
                    { extraStyles = leavingStyles model move
                    , isBursting = False
                    , withTracer = True
                    }
                    model.context.window
                    move
            )


leavingStyles : Model -> Move -> List Style
leavingStyles model move =
    case Move.tileState move of
        Leaving _ order ->
            [ transform [ translate (resourceBankOffsetX model) -100 ]
            , transitionAll 500 [ delay <| modBy 5 order * 80 ]
            ]

        _ ->
            []
