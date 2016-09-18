module TilerDemo exposing (main)

import Dict exposing (Dict)
import Html exposing (Html, img, node)
import Html.App as App
import Html.Events exposing (onWithOptions, Options)
import Html.Attributes exposing (style, src)

import Json.Decode exposing (succeed)

import Tiler exposing (TilingInstruction)

type alias Url = String

type alias Model = 
    { rowCount: Int
    , columnCount: Int
    , origin: Tiler.Tile
    , images : Dict (Int, Int) Url
    }

type Msg = Complete (Int, Int) Url

imageUrl : Tiler.Tile -> Url
imageUrl tile = 
    "https://api.tiles.mapbox.com/v4/mapbox.run-bike-hike/15/" ++ (toString tile.x) ++ "/" ++ (toString tile.y) ++ ".png?access_token=pk.eyJ1IjoiZ3J1bXB5amFtZXMiLCJhIjoiNWQzZjdjMDY1YTI2MjExYTQ4ZWU4YjgwZGNmNjUzZmUifQ.BpRWJBEup08Z9DJzstigvg"

loadingTileImages : Dict (Int, Int) Url -> Tiler.Tile -> Html Msg
loadingTileImages cache tile =
    let lookup = Dict.get (tile.x, tile.y) cache
    in 
      case lookup of
        Just url -> readyImage url
        Nothing -> loadingImage (tile.x, tile.y) (imageUrl tile)

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
    , origin = (Tiler.Tile 16380 10890)
    , images = Dict.empty
    }

update : Msg -> Model -> Model
update message model =
    case message of
      Complete key value ->
          { model | images = Dict.insert key value model.images }

view : Model -> Html Msg
view m =
    Tiler.tile (TilingInstruction m.rowCount m.columnCount m.origin (loadingTileImages m.images))

main = 
    App.beginnerProgram { model = model
                        , view = view
                        , update = update
                        }