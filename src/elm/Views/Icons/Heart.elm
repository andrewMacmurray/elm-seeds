module Views.Icons.Heart exposing (..)

import Config.Color exposing (..)
import Svg exposing (Svg)
import Svg.Attributes exposing (..)


heart : Svg msg
heart =
    Svg.svg
        [ viewBox "0 0 57 50"
        , height "100%"
        , width "100%"
        ]
        [ Svg.g []
            [ Svg.path
                [ d "M28.4 6s.2-.4 1-1.2c6.2-6 16.2-6 22.3 0 6.1 6 6.1 16 0 22l-22.4 22c-.2.3-.6.4-1 .4V6z"
                , fill pinkRed
                ]
                []
            , Svg.path
                [ d "M28.4 6s-.2-.4-1-1.2c-6.2-6-16.2-6-22.3 0-6.1 6-6.1 16 0 22l22.3 22c.3.3.6.4 1 .4V6z"
                , fill crimson
                ]
                []
            ]
        ]


brokenHeart : Svg msg
brokenHeart =
    Svg.svg
        [ viewBox "-5 0 65 49"
        , height "100%"
        , width "100%"
        ]
        [ Svg.g [ fill "none" ]
            [ Svg.path
                [ d "M28 4.5a15.5 15.5 0 0 1 22 21.9l-22 22c-.3.2-.7.4-1 .4v-8.9l-5.7-9.8 5.7-8.7-5.7-8.3L27 5.7l1-1.2z"
                , fill "#B4B4B4"
                , style "transform-origin: bottom; animation: break-right 0.2s linear forwards"
                ]
                []
            , Svg.path
                [ d "M26.4 4.5A15.5 15.5 0 0 0 4.5 26.4l22 22c.3.2.6.4 1 .4v-8.9l-5.6-9.8 5.5-8.7-5.5-8.3 5.5-7.4-1-1.2z"
                , fill "#E2E2E2"
                , style "transform-origin: bottom; animation: break-left 0.2s linear forwards"
                ]
                []
            ]
        ]
