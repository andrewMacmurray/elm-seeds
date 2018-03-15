module Config.Scale exposing (..)

import Window exposing (Size)


tileScaleFactor : Size -> Float
tileScaleFactor window =
    let
        dimension =
            smallestWindowDimension window
    in
        if dimension < 480 then
            0.8
        else if dimension > 480 && dimension < 720 then
            0.98
        else
            1.2


smallestWindowDimension : Size -> Int
smallestWindowDimension { height, width } =
    if height >= width then
        width
    else
        height


scoreIconSize : number
scoreIconSize =
    32


baseTileSizeX : number
baseTileSizeX =
    55


baseTileSizeY : number
baseTileSizeY =
    51


topBarHeight : number
topBarHeight =
    80