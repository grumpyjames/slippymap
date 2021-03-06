module LocatorDemo exposing (main)

import Locator exposing (LatLn, TileAddress, lookup)

import Html exposing (Html, img)
import Html.App as App
import Html.Attributes exposing (style, src)

type alias Place = 
    { name: String
    , latln: LatLn  
    }

type Msg = NoMessages 

model = 
    [ Place "Sydney Opera House" (LatLn -33.8568 151.2153)
    , Place "Statue of Liberty" (LatLn 40.6892 -74.0445)
    , Place "Eiffel Tower" (LatLn 48.8584 2.2945)
    ]

update message model = model

view : List Place -> Html Msg
view model =
    Html.div [] (List.map viewOnePlace model)

imageUrl : (Int, Int) -> String
imageUrl (tx, ty) = 
    "https://api.tiles.mapbox.com/v4/mapbox.run-bike-hike/15/" ++ (toString tx) ++ "/" ++ (toString ty) ++ ".png?access_token=pk.eyJ1IjoiZ3J1bXB5amFtZXMiLCJhIjoiNWQzZjdjMDY1YTI2MjExYTQ4ZWU4YjgwZGNmNjUzZmUifQ.BpRWJBEup08Z9DJzstigvg"

viewOnePlace : Place -> Html Msg
viewOnePlace p =
    let tileAddress = lookup 15 p.latln
        tileUrl = imageUrl tileAddress.tile
    in Html.div [] [titled p.name, image tileUrl]

titled: String -> Html Msg
titled name = Html.text name

image imageUrl = Html.img [src imageUrl] []

main = 
    App.beginnerProgram { model = model
                        , view = view
                        , update = update
                        }