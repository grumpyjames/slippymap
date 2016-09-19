module LazyLoaderDemo exposing (main)

import LazyLoader exposing 
    ( readyImage
    , loadingImage
    , Event(..)
    , Url
    )

import Html exposing (Html)
import Html.App as App
import List exposing (map)

main =
  App.beginnerProgram { model = model, view = view, update = update }

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

type alias Msg = LazyLoader.Event

update : Msg -> Model -> Model
update msg model =
  case msg of
    Complete url -> complete url model

complete : Url -> Model -> Model
complete url model = 
    let f lazyImage = 
        case lazyImage of 
          Ready _ -> lazyImage
          Loading loadingUrl -> if loadingUrl == url then Ready url else lazyImage
    in map f model

view : Model -> Html Msg
view model = 
    let f lazyImage =
        case lazyImage of
          Ready url -> readyImage url
          Loading url -> loadingImage url
    in Html.div [] (map f model)