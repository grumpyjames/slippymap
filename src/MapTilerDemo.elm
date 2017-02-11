module MapTilerDemo exposing (main)

import Dict exposing (Dict)
import Html exposing (Html, img, node)
import Html.App as App
import Html.Events exposing (onWithOptions, Options)
import Html.Attributes exposing (style, src)

import Json.Decode exposing (succeed)

import LazyTiles exposing (loadingTileImages)
import Tiler exposing (TilingInstruction, TileSpec)
import Url exposing (Url)

type alias Model = 
    { rowCount: Int
    , columnCount: Int
    , origin: Tiler.TileSpec
    , images : Dict (Int, Int) Url
    }

type Direction
    = Up
    | Down
    | Left
    | Right

type Msg = Complete (Int, Int) Url
         | Shift Direction

model =
    { rowCount = 3
    , columnCount = 4
    , origin = (TileSpec 16380 10890 15)
    , images = Dict.empty
    }

shift : (Int, Int) -> Tiler.TileSpec -> Tiler.TileSpec
shift (dx, dy) tile =
    TileSpec (tile.x + dx) (tile.y + dy) tile.zoom 

update : Msg -> Model -> Model
update message model =
    case message of
      Complete key value ->
          { model | images = Dict.insert key value model.images }
      Shift d -> 
          case d of
            Up -> { model | origin = shift (0, -1) model.origin }
            Down -> { model | origin = shift (0, 1) model.origin }
            Left -> { model | origin = shift (-1, 0) model.origin }
            Right -> { model | origin = shift (1, 0) model.origin }

px : Int -> String
px pixels = (toString pixels) ++ "px"

fixedWidth : List (Html a) -> Html a
fixedWidth htmls = 
    let width = (List.length htmls) * 256
    in Html.div [style [("width", (px width))]] htmls

view : Model -> Html Msg
view m =
    let rawTiles = 
            Tiler.tile { rowCount = m.rowCount
                       , columnCount = m.columnCount
                       , origin = m.origin
                       , viewTile = (loadingTileImages m.images)
                       , viewRow = fixedWidth
                       , outerAttributes = []
                       }
        tiles = App.map (\imageLoaded -> Complete imageLoaded.coordinate imageLoaded.url) rawTiles
    in Html.div [] [controls, tiles]

controls : Html Msg
controls = 
    let 
        shiftButton shift text = 
            Html.button 
                [(Html.Events.on "click" (succeed (Shift shift)))] 
                [Html.text text]
        upButton = shiftButton Up "North"
        downButton = shiftButton Down "South"
        leftButton = shiftButton Left "West"
        rightButton = shiftButton Right "East"
    in Html.div [] [upButton, downButton, leftButton, rightButton]

main = 
    App.beginnerProgram { model = model
                        , view = view
                        , update = update
                        }