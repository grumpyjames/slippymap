module LazyTiles exposing 
    ( loadingTileImages
    , imageUrl
    , ImageLoaded)

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
    let key = Tiler.fold tile (\x y z -> (x, y))
        lookup = Dict.get key cache
    in 
      case lookup of
        Just url -> readyImage url
        Nothing -> loadingImage key (imageUrl tile)

accessToken = "pk.eyJ1IjoiZ3J1bXB5amFtZXMiLCJhIjoiNWQzZjdjMDY1YTI2MjExYTQ4ZWU4YjgwZGNmNjUzZmUifQ.BpRWJBEup08Z9DJzstigvg"

imageUrl : Tiler.Tile -> Url
imageUrl tile =
    let toUrl x y z = 
        "https://api.tiles.mapbox.com/v4/mapbox.run-bike-hike/" 
        ++ (toString z) ++ "/"
        ++ (toString x) ++ "/"
        ++ (toString y) 
        ++ ".png?access_token="
        ++ accessToken
    in Tiler.fold tile toUrl

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