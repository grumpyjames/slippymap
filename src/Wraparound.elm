module Wraparound exposing (main)

import FixedViewport exposing (calculateDimensions, Requirements, Dimensions)
import FixedViewportRenderer exposing (render)
import LazyTiles exposing (loadingTileImages)
import Locator exposing (LatLn, TileAddress, lookup)
import Tiler
import Url exposing (Url)

import Dict exposing (Dict)
import Html exposing (Html, img)
import Html.App as App
import Html.Attributes exposing (style, src)
import Html.Events as Events
import Platform.Cmd as Cmd
import Time exposing (Time, millisecond)

type alias Model = 
    { location: LatLn
    , x: Int
    , y: Int
    , images : Dict (Int, Int) Url
    }

model = Model (LatLn 0 170) 712 466 Dict.empty

type Msg 
    = Complete (Int, Int) Url
    | Tick Time

update : Msg -> Model -> (Model, Cmd Msg)
update message model = 
    case message of
      Complete key url ->
          ( { model | images = Dict.insert key url model.images }, Cmd.none )
      Tick time ->
          ( { model | location = rotateOneDegree model.location }, Cmd.none )

rotateOneDegree : LatLn -> LatLn
rotateOneDegree latln = 
    let newLongitude = latln.longitude + 1
    in LatLn latln.latitude newLongitude 

mapView : Model -> Html Msg
mapView model =
    let zoom = 3
        tileSize = 256
        dimensions = calculateDimensions (Requirements model.location zoom tileSize model.x model.y)
        map = render model.images dimensions 
        lift = \imageLoaded -> Complete imageLoaded.coordinate imageLoaded.url
    in App.map lift map

view : Model -> Html Msg
view model = 
    let map = mapView model
    in Html.div [] [ map ]

subs : Model -> Sub Msg
subs m = Time.every (25 * millisecond) Tick

main =
    App.program 
           { init = (model, Cmd.none)
           , update = update
           , subscriptions = subs
           , view = view
           }