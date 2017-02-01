module MapTilerDemo exposing (main)

import Dict exposing (Dict)
import Html exposing (Html, img, node)
import Html.App as App
import Html.Events exposing (onWithOptions, Options)
import Html.Attributes exposing (style, src)

import Json.Decode exposing (succeed)

import LazyTiles exposing (imageUrl)
import Tiler exposing (TilingInstruction, TileSpec)
import Url exposing (Url)

type alias Model = 
    { rowCount: Int
    , columnCount: Int
    , origin: Tiler.Tile
    , images : Dict (Int, Int) Url
    }

type Direction
    = Up
    | Down
    | Left
    | Right

type Msg = Complete (Int, Int) Url
         | Shift Direction

loadingTileImages : Dict (Int, Int) Url -> Tiler.Tile -> Html Msg
loadingTileImages cache tile =
    let key = Tiler.fold tile (\x y z -> (x, y))
        lookup = Dict.get key cache
    in 
      case lookup of
        Just url -> readyImage url
        Nothing -> loadingImage key (imageUrl tile)

readyImage : Url -> Html Msg
readyImage url =
    let attrs = [ src url, style [ ( "float", "left" ) ] ]
    in img attrs [] 

loadingImage : (Int, Int) -> Url -> Html Msg
loadingImage coordinate url =
    let 
        divStyles =
            style [ ("width", "256px")
                  , ("height", "256px")
                  , ("float", "left")
                  , ("display", "flex")
                  ]
        loadingGifAttrs = 
            [ src "loading.gif"
            , style [ ( "float", "left" )
                    , ( "display", "block")
                    , ( "margin", "auto") ]
            ]
        loadingImageAttrs = 
            [ src url
            , style [ ("display", "none" ) ]
            , onWithOptions "load" (Options False False) (succeed (Complete coordinate url))
            ]
    in node "div" [divStyles] [(img loadingGifAttrs []), (img loadingImageAttrs [])]

model =
    { rowCount = 3
    , columnCount = 4
    , origin = (Tiler.newTile (TileSpec 16380 10890 15))
    , images = Dict.empty
    }

shift : (Int, Int) -> Tiler.Tile -> Tiler.Tile
shift (dx, dy) tile =
    Tiler.fold tile (\x y z -> Tiler.newTile (TileSpec (x + dx) (y + dy) z)) 

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
    let tiles = 
            Tiler.tile { rowCount = m.rowCount
                       , columnCount = m.columnCount
                       , origin = m.origin
                       , viewTile = (loadingTileImages m.images)
                       , viewRow = fixedWidth
                       , outerAttributes = []
                       }
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