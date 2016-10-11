module TilerDemo exposing (main)

import Html exposing (Html)
import Html.App as App

import Tiler exposing (TilingInstruction)

type alias Model = TilingInstruction Msg

type Msg = NoOp

describe : Tiler.Tile -> Html Msg
describe tile =
    Html.text ("(" ++ (toString tile.x) ++ ", " ++ (toString tile.y) ++ ")") 

model =
    TilingInstruction 3 5 (Tiler.Tile 3 5) describe (\htmls -> Html.div [] htmls)

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