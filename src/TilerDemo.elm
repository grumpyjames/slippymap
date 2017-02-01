module TilerDemo exposing (main)

import Html exposing (Html)
import Html.App as App

import Tiler exposing (TilingInstruction)

type alias Model = TilingInstruction Msg

type Msg = NoOp

describe : Tiler.Tile -> Html Msg
describe tile =
    let f x y z = Html.text ("(" ++ (toString x) ++ ", " ++ (toString y) ++ ")") 
    in Tiler.fold tile f

model =
    TilingInstruction 3 5 (Tiler.newTile (Tiler.TileSpec 3 5 0)) describe (\htmls -> Html.div [] htmls) []

update : Msg -> Model -> Model
update message model = model

view : Model -> Html Msg
view m =
    Tiler.tile m

main = 
    App.beginnerProgram { model = model
                        , view = Tiler.tile
                        , update = update
                        }