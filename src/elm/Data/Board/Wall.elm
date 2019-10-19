module Data.Board.Wall exposing
    ( Config
    , addToBoard
    , borders
    , centerColumns
    , corners
    , innerBorders
    , s
    , toCoords
    , w
    , walls
    , withColor
    )

import Css.Color as Color exposing (Color)
import Data.Board as Board
import Data.Board.Types exposing (Block(..), Board, Coord)



-- Visually Construct wall coordinates


type Config
    = Config ( Color, Coord )


centerColumns : List Coord
centerColumns =
    toCoords
        [ [ s, s, s, w, w, s, s, s ]
        , [ s, s, s, w, w, s, s, s ]
        , [ s, s, s, w, w, s, s, s ]
        , [ s, s, s, w, w, s, s, s ]
        , [ s, s, s, w, w, s, s, s ]
        , [ s, s, s, w, w, s, s, s ]
        , [ s, s, s, w, w, s, s, s ]
        , [ s, s, s, w, w, s, s, s ]
        ]


corners : List Coord
corners =
    toCoords
        [ [ w, w, s, s, s, s, s, s ]
        , [ w, s, s, s, s, s, s, s ]
        , [ s, s, s, s, s, s, s, s ]
        , [ s, s, s, s, s, s, s, s ]
        , [ s, s, s, s, s, s, s, s ]
        , [ s, s, s, s, s, s, s, s ]
        , [ s, s, s, s, s, s, s, w ]
        , [ s, s, s, s, s, s, w, w ]
        ]


innerBorders : List Coord
innerBorders =
    toCoords
        [ [ s, s, s, s, s, s, s, s ]
        , [ s, w, w, s, s, w, w, s ]
        , [ s, w, s, s, s, s, w, s ]
        , [ s, s, s, s, s, s, s, s ]
        , [ s, s, s, s, s, s, s, s ]
        , [ s, w, s, s, s, s, w, s ]
        , [ s, w, w, s, s, w, w, s ]
        , [ s, s, s, s, s, s, s, s ]
        ]


borders : List Coord
borders =
    toCoords
        [ [ w, w, s, w, w, s, w, w ]
        , [ w, s, s, s, s, s, s, w ]
        , [ s, s, s, s, s, s, s, s ]
        , [ w, s, s, s, s, s, s, w ]
        , [ w, s, s, s, s, s, s, w ]
        , [ s, s, s, s, s, s, s, s ]
        , [ w, s, s, s, s, s, s, w ]
        , [ w, w, s, w, w, s, w, w ]
        ]


w : Bool
w =
    True


s : Bool
s =
    False


toCoords : List (List Bool) -> List Coord
toCoords allWalls =
    allWalls
        |> List.indexedMap (\i r -> List.indexedMap (toCoord i) r)
        |> List.concat
        |> List.concat


toCoord : Int -> Int -> Bool -> List Coord
toCoord i j x =
    if x then
        [ ( i, j ) ]

    else
        []



-- Add Walls to board


walls : List Coord -> List Config
walls =
    withColor Color.blockYellow


addToBoard : List Config -> Board -> Board
addToBoard walls_ board =
    List.foldl addWall board walls_


addWall : Config -> Board -> Board
addWall (Config ( wallColor, coord )) =
    Board.placeAt coord <| Wall wallColor


withColor : Color -> List Coord -> List Config
withColor color =
    List.map (\coord -> Config ( color, coord ))
