module LazyLoader exposing (Event(..), Url, readyImage, loadingImage)

import Html exposing (Html, img)
import Html.Events exposing (onWithOptions, Options)
import Html.Attributes exposing (style, src)

import Json.Decode exposing (succeed)

type alias Url = String
type Event = Complete Url

readyImage : Url -> Html Event
readyImage url =
    let attrs = [ src url, style [ ( "float", "left" ) ] ]
    in img attrs [] 

loadingImage : Url -> Html Event
loadingImage url =
    let 
        loadingGifAttrs = 
            [ src "loading.gif"
            , style [ ( "float", "left" ) ]
            ]
        loadingImageAttrs = 
            [ src url
            , style [ ("display", "none" ) ]
            , onWithOptions "load" (Options False False) (succeed (Complete url))
            ]
    in Html.div [] [(img loadingGifAttrs []), (img loadingImageAttrs [])]