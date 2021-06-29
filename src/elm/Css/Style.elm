module Css.Style exposing
    ( Style
    , background
    , backgroundColor
    , border
    , borderNone
    , classes
    , color
    , compose
    , height
    , marginTop
    , none
    , opacity
    , property
    , renderStyles_
    , style
    , svg
    , transform
    , transformOrigin
    , width
    )

import Css.Color as Color
import Css.Transform as Transform exposing (Transform)
import Html
import Html.Attributes
import Svg
import Svg.Attributes
import Utils.Unit as Unit


type Style
    = Property String String
    | Raw String


property : String -> String -> Style
property =
    Property


compose : List Style -> Style
compose =
    Raw << renderStyles_



-- Html


style : List Style -> Html.Attribute msg
style =
    Html.Attributes.attribute "style" << renderStyles_



-- Svg


svg : List Style -> Svg.Attribute msg
svg =
    Svg.Attributes.style << renderStyles_



-- Render Styles to Raw String


renderStyles_ : List Style -> String
renderStyles_ =
    List.filter isNonEmpty
        >> List.map styleToString_
        >> String.join ";"


styleToString_ : Style -> String
styleToString_ s =
    case s of
        Property prop val ->
            prop ++ ":" ++ val

        Raw val ->
            val


isNonEmpty : Style -> Bool
isNonEmpty s =
    case s of
        Property prop val ->
            nonEmpty prop && nonEmpty val

        Raw _ ->
            True


nonEmpty : String -> Bool
nonEmpty =
    String.trim >> String.isEmpty >> not



-- Properties


none : Style
none =
    property "" ""


transform : List Transform -> Style
transform transforms =
    property "transform" (Transform.render transforms)


transformOrigin : String -> Style
transformOrigin =
    property "transform-origin"


marginTop : Float -> Style
marginTop n =
    property "margin-top" (Unit.px (round n))


color : String -> Style
color c =
    property "color" c


borderNone : Style
borderNone =
    property "border" "none"


border : Float -> Color.Color -> Style
border n c =
    property "border" (String.join " " [ Unit.px (round n), "solid", c ])


backgroundColor : String -> Style
backgroundColor =
    property "background-color"


background : String -> Style
background =
    property "background"


width : Float -> Style
width n =
    property "width" (Unit.px (round n))


height : Float -> Style
height h =
    property "height" (Unit.px (round h))


opacity : Float -> Style
opacity o =
    property "opacity" (String.fromFloat o)



-- Class Helpers


classes : List String -> Html.Attribute msg
classes =
    Html.Attributes.class << String.join " "
