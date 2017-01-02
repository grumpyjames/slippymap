module CentreDemo exposing (main)

import LazyTiles exposing (loadingTileImages)
import Locator exposing (LatLn, TileAddress, lookup)
import Tiler
import Url exposing (Url)

import Debug exposing (log)
import Dict exposing (Dict)
import Html exposing (Html, img)
import Html.App as App
import Html.Attributes exposing (style, src)

type alias Model = 
    { location: LatLn
    , x: Int
    , y: Int
    , images : Dict (Int, Int) Url
    }

model = Model (LatLn 48.858193 2.2940533) 712 466 Dict.empty

type Msg = Complete (Int, Int) Url

update : Msg -> Model -> Model
update message model = 
    case message of
      Complete key url ->
          { model | images = Dict.insert key url model.images }

calculateTileCount : Int -> (Int, Int) -> (Int, Int)
calculateTileCount tileSize (x, y) =
    ((x // tileSize) + 3, (y // tileSize) + 3)

calculateOffsets : Int -> (Int, Int) -> (Int, Int) -> (Int, Int) -> (Int, Int)
calculateOffsets tileSize (x, y) (columnCount, rowCount) (xpixel, ypixel) =
    let xoff = (columnCount // 2) * tileSize
        yoff = (rowCount // 2) * tileSize
    in
    ( (x // 2) - (xoff + xpixel)
    , (y // 2) - (yoff + ypixel)
    )

fixedWidth : Int -> List (Html a) -> Html a
fixedWidth tileSize htmls = 
    let width = (List.length htmls) * tileSize
    in Html.div [style [("width", (px width))]] htmls

px : Int -> String
px pixels = (toString pixels) ++ "px"

view : Model -> Html Msg
view model = 
    let zoom = 15
        tileSize = 256
        (columnCount, rowCount) = calculateTileCount tileSize (model.x, model.y)
        tileAddress = lookup 15 model.location
        (centreTx, centreTy) = tileAddress.tile
        (left, top) = calculateOffsets tileSize (model.x, model.y) (columnCount, rowCount) tileAddress.pixelWithinTile
        tiles = Tiler.tile { rowCount = rowCount
                           , columnCount = columnCount
                           , origin = Tiler.Tile (centreTx - (columnCount // 2)) (centreTy - (rowCount // 2)) zoom
                           , viewTile = (loadingTileImages model.images)
                           , viewRow = fixedWidth tileSize
                           , outerAttributes = [ style [("position", "relative"), ("top", px top), ("left", px left)] ]
                           }
        lift = \imageLoaded -> Complete imageLoaded.coordinate imageLoaded.url
    in Html.div [ style [("width", px model.x), ("height", px model.y), ("overflow", "hidden")] ] [ App.map lift tiles ]

main =
    App.beginnerProgram { model = model
                        , view = view
                        , update = update
                        }