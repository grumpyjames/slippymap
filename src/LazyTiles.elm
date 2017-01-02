module LazyTiles exposing (loadingTileImages, ImageLoaded)

import Url exposing (Url)
import Tiler

import Dict exposing (Dict)
import Html exposing (Html, img)
import Html.Events exposing (onWithOptions, Options)
import Html.Attributes exposing (style, src)
import Json.Decode exposing (succeed)


type alias ImageLoaded =
    { coordinate: (Int, Int)
    , url: Url
    }

loadingTileImages : Dict (Int, Int) Url -> Tiler.Tile -> Html ImageLoaded
loadingTileImages cache tile =
    let lookup = Dict.get (tile.x, tile.y) cache
    in 
      case lookup of
        Just url -> readyImage url
        Nothing -> loadingImage (tile.x, tile.y) (imageUrl tile)


imageUrl : Tiler.Tile -> Url
imageUrl tile = 
    "https://api.tiles.mapbox.com/v4/mapbox.run-bike-hike/15/" ++ (toString tile.x) ++ "/" ++ (toString tile.y) ++ ".png?access_token=pk.eyJ1IjoiZ3J1bXB5amFtZXMiLCJhIjoiNWQzZjdjMDY1YTI2MjExYTQ4ZWU4YjgwZGNmNjUzZmUifQ.BpRWJBEup08Z9DJzstigvg"

readyImage : Url -> Html ImageLoaded
readyImage url =
    let attrs = [ src url, style [ ( "float", "left" ) ] ]
    in img attrs [] 

loadingImage : (Int, Int) -> Url -> Html ImageLoaded
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
            , onWithOptions "load" (Options False False) (succeed (ImageLoaded coordinate url))
            ]
    in Html.div [divStyles] [(img loadingGifAttrs []), (img loadingImageAttrs [])]