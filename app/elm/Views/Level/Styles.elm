module Views.Level.Styles exposing (..)

import Data.Board.Block exposing (getTileState)
import Data.Board.Score exposing (scoreTileTypes)
import Data.Board.Tile exposing (getTileType, growingOrder, isDragging, isLeaving, leavingOrder, tileColorMap)
import Data.Color exposing (blockYellow)
import Dict exposing (Dict)
import Helpers.Style exposing (animationStyle, backgroundColor, classes, displayStyle, emptyStyle, fillModeStyle, heightStyle, marginTop, ms, opacityStyle, px, scale, size, transformStyle, transitionDelayStyle, transitionStyle, translate, translateScale, widthStyle)
import Model as MainModel exposing (Style)
import Scenes.Level.Model exposing (..)


boardMarginTop : MainModel.Model -> Style
boardMarginTop model =
    marginTop <| boardOffsetTop model


boardOffsetTop : MainModel.Model -> Int
boardOffsetTop model =
    (model.window.height - boardHeight model.levelModel) // 2 + model.levelModel.topBarHeight // 2


boardHeight : Model -> Int
boardHeight model =
    round model.tileSize.y * model.boardScale


boardWidth : Model -> Int
boardWidth { tileSize, boardScale } =
    round tileSize.x * boardScale


tileCoordsStyles : Model -> Coord -> List Style
tileCoordsStyles model coord =
    let
        ( y, x ) =
            tilePosition model coord
    in
        [ transformStyle <| translate x y ]


tilePosition : Model -> Coord -> ( Float, Float )
tilePosition model ( y, x ) =
    ( (toFloat y) * model.tileSize.y
    , (toFloat x) * model.tileSize.x
    )


wallStyles : Move -> List Style
wallStyles ( _, block ) =
    case block of
        Wall ->
            [ backgroundColor blockYellow
            , widthStyle 45
            , heightStyle 45
            ]

        _ ->
            []


enteringStyles : Move -> List Style
enteringStyles ( _, block ) =
    let
        tile =
            getTileState block
    in
        case tile of
            Entering tile ->
                [ animationStyle "bounce 0.4s ease"
                ]

            _ ->
                []


growingStyles : Move -> List Style
growingStyles ( coord, block ) =
    let
        tile =
            getTileState block

        transitionDelay =
            ((growingOrder block) % 5) * 70
    in
        case tile of
            Growing SeedPod _ ->
                [ transformStyle <| scale 4
                , transitionStyle "0.4s ease"
                , opacityStyle 0
                , transitionDelayStyle transitionDelay
                , ( "pointer-events", "none" )
                ]

            Growing Seed _ ->
                [ animationStyle "bulge 0.5s ease"
                ]

            _ ->
                []


fallingStyles : Move -> List Style
fallingStyles ( _, block ) =
    let
        tile =
            getTileState block
    in
        case tile of
            Falling tile distance ->
                [ animationStyle <| "fall-" ++ (toString (distance - 1)) ++ " 0.5s ease"
                , fillModeStyle "forwards"
                ]

            _ ->
                []


leavingStyles : MainModel.Model -> Move -> List Style
leavingStyles model (( _, tile ) as move) =
    if isLeaving tile then
        [ transitionStyle "0.8s ease"
        , opacityStyle 0.2
        , transitionDelayStyle <| ((leavingOrder tile) % 5) * 80
        , handleExitDirection move model
        ]
    else
        []


handleExitDirection : Move -> MainModel.Model -> Style
handleExitDirection ( coord, block ) model =
    let
        tile =
            getTileState block
    in
        case tile of
            Leaving Rain _ ->
                transformStyle <| getLeavingStyle Rain model

            Leaving Sun _ ->
                transformStyle <| getLeavingStyle Sun model

            Leaving Seed _ ->
                transformStyle <| getLeavingStyle Seed model

            _ ->
                emptyStyle


getLeavingStyle : TileType -> MainModel.Model -> String
getLeavingStyle tileType model =
    newLeavingStyles model
        |> Dict.get (toString tileType)
        |> Maybe.withDefault ""


newLeavingStyles : MainModel.Model -> Dict String String
newLeavingStyles model =
    model.levelModel.tileProbabilities
        |> scoreTileTypes
        |> List.indexedMap (prepareLeavingStyle model)
        |> Dict.fromList


prepareLeavingStyle : MainModel.Model -> Int -> TileType -> ( String, String )
prepareLeavingStyle model i tileType =
    ( toString tileType
    , translateScale (exitXDistance i model.levelModel) -(exitYdistance model) 0.5
    )


exitXDistance : Int -> Model -> Int
exitXDistance n model =
    let
        scoreWidth =
            model.scoreIconSize * 2

        scoreBarWidth =
            (List.length model.tileProbabilities) * scoreWidth

        baseOffset =
            (boardWidth model - scoreBarWidth) // 2
    in
        baseOffset + (n * scoreWidth) + (model.scoreIconSize + 3)


exitYdistance : MainModel.Model -> Int
exitYdistance model =
    (boardOffsetTop model) - 9


moveTracerStyles : Model -> Move -> List Style
moveTracerStyles model (( coord, tile ) as move) =
    if isDragging tile then
        [ animationStyle "bulge-fade 0.8s ease"
        , fillModeStyle "forwards"
        ]
    else if isLeaving tile then
        [ displayStyle "none"
        ]
    else
        []


draggingStyles : Model -> Move -> List Style
draggingStyles model ( _, tileState ) =
    if model.moveShape == Just Square then
        [ transitionStyle "0.5s ease"
        ]
    else if isLeaving tileState then
        [ transitionStyle "0.1s ease"
        ]
    else if isDragging tileState then
        [ transformStyle <| scale 0.8
        , transitionStyle "0.3s ease"
        ]
    else
        []


tileWidthHeightStyles : Model -> List Style
tileWidthHeightStyles { tileSize } =
    [ widthStyle tileSize.x
    , heightStyle tileSize.y
    ]


centerBlock : String
centerBlock =
    "ma absolute top-0 left-0 right-0 bottom-0"
