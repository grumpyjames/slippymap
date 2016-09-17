module LazyLoader exposing (main)

import Html exposing (Html, img, node)
import Html.App as App
import Html.Events exposing (onWithOptions, Options)
import Html.Attributes exposing (style, src)

import Json.Decode exposing (succeed)

import List exposing (map)

main =
  App.beginnerProgram { model = model, view = view, update = update }

type alias Url = String

type LazyImage = Loading Url
               | Ready Url

type alias Model =
    List LazyImage

model : Model
model = 
    [ (Loading "https://api.tiles.mapbox.com/v4/mapbox.run-bike-hike/15/16381/10898.png?access_token=pk.eyJ1IjoiZ3J1bXB5amFtZXMiLCJhIjoiNWQzZjdjMDY1YTI2MjExYTQ4ZWU4YjgwZGNmNjUzZmUifQ.BpRWJBEup08Z9DJzstigvg")
    , (Loading "https://api.tiles.mapbox.com/v4/mapbox.run-bike-hike/15/16382/10898.png?access_token=pk.eyJ1IjoiZ3J1bXB5amFtZXMiLCJhIjoiNWQzZjdjMDY1YTI2MjExYTQ4ZWU4YjgwZGNmNjUzZmUifQ.BpRWJBEup08Z9DJzstigvg")
    , (Loading "https://api.tiles.mapbox.com/v4/mapbox.run-bike-hike/15/16383/10898.png?access_token=pk.eyJ1IjoiZ3J1bXB5amFtZXMiLCJhIjoiNWQzZjdjMDY1YTI2MjExYTQ4ZWU4YjgwZGNmNjUzZmUifQ.BpRWJBEup08Z9DJzstigvg")
    , (Loading "https://api.tiles.mapbox.com/v4/mapbox.run-bike-hike/15/16384/10898.png?access_token=pk.eyJ1IjoiZ3J1bXB5amFtZXMiLCJhIjoiNWQzZjdjMDY1YTI2MjExYTQ4ZWU4YjgwZGNmNjUzZmUifQ.BpRWJBEup08Z9DJzstigvg")
    , (Loading "https://api.tiles.mapbox.com/v4/mapbox.run-bike-hike/15/16385/10898.png?access_token=pk.eyJ1IjoiZ3J1bXB5amFtZXMiLCJhIjoiNWQzZjdjMDY1YTI2MjExYTQ4ZWU4YjgwZGNmNjUzZmUifQ.BpRWJBEup08Z9DJzstigvg")
    , (Loading "https://api.tiles.mapbox.com/v4/mapbox.run-bike-hike/15/16386/10898.png?access_token=pk.eyJ1IjoiZ3J1bXB5amFtZXMiLCJhIjoiNWQzZjdjMDY1YTI2MjExYTQ4ZWU4YjgwZGNmNjUzZmUifQ.BpRWJBEup08Z9DJzstigvg")
    , (Loading "https://api.tiles.mapbox.com/v4/mapbox.run-bike-hike/15/16387/10898.png?access_token=pk.eyJ1IjoiZ3J1bXB5amFtZXMiLCJhIjoiNWQzZjdjMDY1YTI2MjExYTQ4ZWU4YjgwZGNmNjUzZmUifQ.BpRWJBEup08Z9DJzstigvg")
 ]

type Msg = Complete Url

update : Msg -> Model -> Model
update msg model =
  case msg of
    Complete url -> complete url model

complete : Url -> Model -> Model
complete url model = 
    let f li = 
        case li of 
          Ready _ -> li
          Loading u -> if u==url then Ready u else li
    in map f model

view : Model -> Html Msg
view model = 
    let f li =
        case li of
          Ready u -> readyImage u
          Loading u -> loadingImage u
    in node "div" [] (map f model)


readyImage : Url -> Html Msg
readyImage u =
    let attrs = [ src u, style [ ( "float", "left" ) ] ]
    in img attrs [] 

loadingImage : Url -> Html Msg
loadingImage u =
    let 
        loadingGifAttrs = 
            [ src "loading.gif"
            , style [ ( "float", "left" ) ]
            ]
        loadingImageAttrs = 
            [ src u
            , style [ ("display", "none" ) ]
            , onWithOptions "load" (Options False False) (succeed (Complete u))
            ]
    in node "div" [] [(img loadingGifAttrs []), (img loadingImageAttrs [])]