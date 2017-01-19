module CentreDemo exposing (main)

import FixedViewport exposing (calculateDimensions, Requirements, Dimensions)
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
        dimensions = calculateDimensions (Requirements model.location zoom tileSize model.x model.y)
        tiles = Tiler.tile { rowCount = dimensions.rowCount
                           , columnCount = dimensions.columnCount
                           , origin = dimensions.origin
                           , viewTile = (loadingTileImages model.images)
                           , viewRow = fixedWidth tileSize
                           , outerAttributes = [ style [("position", "relative"), ("top", px dimensions.top), ("left", px dimensions.left)] ]
                           }
        lift = \imageLoaded -> Complete imageLoaded.coordinate imageLoaded.url
    in Html.div [ style [("width", px model.x), ("height", px model.y), ("overflow", "hidden")] ] [ App.map lift tiles ]

main =
    App.beginnerProgram { model = model
                        , view = view
                        , update = update
                        }