module Data.Level.Board.Generate exposing (..)

import Data.Level.Board.Probabilities exposing (tileProbability)
import Data.Level.Board.Tile exposing (growingOrder, isGrowing, isSeedTile)
import Dict
import Random exposing (Generator)
import Scenes.Hub.Types exposing (..)
import Scenes.Level.Types as Level exposing (..)


-- Growing Tiles


insertNewSeeds : List TileType -> Board -> Board
insertNewSeeds newSeeds board =
    let
        seedsToAdd =
            board
                |> filterGrowing
                |> Dict.toList
                |> List.map2 setGrowingSeed newSeeds
                |> Dict.fromList
    in
        Dict.union seedsToAdd board


setGrowingSeed : TileType -> ( Coord, Block ) -> ( Coord, Block )
setGrowingSeed tile ( coord, block ) =
    ( coord, Space <| Growing tile <| growingOrder block )


generateNewSeeds : List TileSetting -> Board -> Cmd Level.Msg
generateNewSeeds tileSettings board =
    tileSettings
        |> filterSeedSettings
        |> tileGenerator
        |> Random.list (numberOfGrowingPods board)
        |> Random.generate InsertGrowingSeeds


filterSeedSettings : List TileSetting -> List TileSetting
filterSeedSettings tileSettings =
    tileSettings |> List.filter (\s -> isSeedTile s.tileType)


numberOfGrowingPods : Board -> Int
numberOfGrowingPods board =
    board
        |> filterGrowing
        |> Dict.size


getGrowingCoords : Board -> List Coord
getGrowingCoords board =
    board
        |> filterGrowing
        |> Dict.keys


filterGrowing : Board -> Board
filterGrowing board =
    board |> Dict.filter (\_ tile -> isGrowing tile)



-- Entering Tiles


insertNewEnteringTiles : List TileType -> Board -> Board
insertNewEnteringTiles newTiles board =
    let
        tilesToAdd =
            board
                |> getEmptyCoords
                |> List.map2 (\tile coord -> ( coord, Space <| Entering tile )) newTiles
                |> Dict.fromList
    in
        Dict.union tilesToAdd board


generateEnteringTiles : List TileSetting -> Board -> Cmd Level.Msg
generateEnteringTiles tileSettings board =
    (tileGenerator tileSettings)
        |> Random.list (numberOfEmpties board)
        |> Random.generate InsertEnteringTiles


numberOfEmpties : Board -> Int
numberOfEmpties board =
    board
        |> filterEmpties
        |> Dict.size


getEmptyCoords : Board -> List Coord
getEmptyCoords board =
    board
        |> filterEmpties
        |> Dict.keys


filterEmpties : Board -> Board
filterEmpties board =
    board |> Dict.filter (\_ tile -> tile == Space Empty)



-- Generate Board


makeBoard : Int -> List TileType -> Board
makeBoard scale tiles =
    tiles
        |> List.map (Static >> Space)
        |> List.map2 (,) (makeCoords scale)
        |> Dict.fromList


makeCoords : Int -> List Coord
makeCoords x =
    List.concatMap (rangeToCoord x) (makeRange x)


rangeToCoord : Int -> Int -> List Coord
rangeToCoord y x =
    makeRange y |> List.map (\y -> ( x, y ))


makeRange : Int -> List Int
makeRange n =
    List.range 0 (n - 1)


generateInitialTiles : LevelData -> Int -> Cmd Level.Msg
generateInitialTiles levelData x =
    Random.list (x * x) (tileGenerator levelData.tileSettings)
        |> Random.generate (InitTiles levelData.walls)



-- Random Tile Generator


tileGenerator : List TileSetting -> Generator TileType
tileGenerator tileSettings =
    Random.int 0 (totalProbability tileSettings) |> Random.map (tileProbability tileSettings)


totalProbability : List TileSetting -> Int
totalProbability tileSettings =
    tileSettings
        |> List.map .probability
        |> List.sum
