module CentreDemo exposing (main)

import FixedViewport exposing (calculateDimensions, Requirements, Dimensions)
import LazyTiles exposing (loadingTileImages)
import Locator exposing (LatLn, TileAddress, lookup)
import Tiler
import Url exposing (Url)

import Dict exposing (Dict)
import Html exposing (Html, img)
import Html.App as App
import Html.Attributes exposing (style, src)
import Html.Events as Events

type alias Model = 
    { location: LatLn
    , x: Int
    , y: Int
    , images : Dict (Int, Int) Url
    }

type alias Place = 
    { name: String
    , latln: LatLn  
    }

laTourEiffel = Place "Eiffel Tower" (LatLn 48.8584 2.2945)

places = 
    [ Place "Sydney Opera House" (LatLn -33.8568 151.2153)
    , Place "Statue of Liberty" (LatLn 40.6892 -74.0445)
    , laTourEiffel
    ]


model = Model laTourEiffel.latln 712 466 Dict.empty

type Msg 
    = Complete (Int, Int) Url
    | Goto LatLn

update : Msg -> Model -> Model
update message model = 
    case message of
      Complete key url ->
          { model | images = Dict.insert key url model.images }
      Goto latln ->
          { model | location = latln }

fixedWidth : Int -> List (Html a) -> Html a
fixedWidth tileSize htmls = 
    let width = (List.length htmls) * tileSize
    in Html.div [style [("width", (px width))]] htmls

px : Int -> String
px pixels = (toString pixels) ++ "px"

mapView : Model -> Html Msg
mapView model =
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

buttons : Html Msg
buttons = 
    let button = \place -> Html.button [Events.onClick (Goto place.latln)] [Html.text place.name] 
    in Html.div [] (List.map button places)

view : Model -> Html Msg
view model = 
    let map = mapView model
    in Html.div [] [ buttons, map ]

main =
    App.beginnerProgram { model = model
                        , view = view
                        , update = update
                        }