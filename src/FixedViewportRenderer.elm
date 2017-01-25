module FixedViewportRenderer exposing (render)

import FixedViewport exposing (Dimensions)
import LazyTiles exposing (loadingTileImages, ImageLoaded)
import Tiler
import Url exposing (Url)

import Dict exposing (Dict)
import Html exposing (Html)
import Html.Attributes exposing (style)

render: Dict (Int, Int) Url -> Dimensions -> Html ImageLoaded
render tileCache dimensions =
    let containerAttributes = 
            [ style 
              [ ("position", "relative")
              , ("top", px dimensions.top)
              , ("left", px dimensions.left)
              ]
            ]
        viewportStyle =
            style 
              [ ("width", px dimensions.width)
              , ("height", px dimensions.height)
              , ("overflow", "hidden")]
        tiles = Tiler.tile 
            { rowCount = dimensions.rowCount
            , columnCount = dimensions.columnCount
            , origin = dimensions.origin
            , viewTile = (loadingTileImages tileCache)
            , viewRow = fixedWidth dimensions.tileSize
            , outerAttributes = containerAttributes
            }
    in Html.div [ viewportStyle ] [ tiles ]

fixedWidth : Int -> List (Html a) -> Html a
fixedWidth tileSize htmls = 
    let width = (List.length htmls) * tileSize
    in Html.div [style [("width", (px width))]] htmls

px : Int -> String
px pixels = (toString pixels) ++ "px"
