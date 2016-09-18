### A generic tiling function in elm

As far as I know, all the popular web mapping solutions are
underpinned by a collection of tiles. The map of the globe (usually in
a
[web mercator projection](https://en.wikipedia.org/wiki/Web_Mercator))
is split into a number of square tiles, the precise number depending
on how closely we're looking at the map.

Typically each tile is a separate image (although there are movements
towards serving vector information and rendering to SVG, this is far
too modern for my tiny brain so I will deny their existence for now) -
drawing a large map usually means requesting several images and tiling
them.

We've written a lazy loader for these tiled images; today we'll write
a tiny tiling implementation to form the next step.

### Abstractions I made earlier

<code>
type alias Tile =
    { x: Int
    , y: Int
    }

type alias TilingInstruction a = 
    { rowCount: Int
    , columnCount: Int
    , origin: Tile
    , view: Tile -> Html a
    }
</code>

We don't necessarily want our tiler to know precisely what tiles it is
going to be arranging, so we create this generic definition of a tile,
and allow our instructions to specify how a tile should be rendered.

This has the handy side effect of allowing us to write a very simple
demonstration program to give us confidence that our tiler is doing
the right thing. Writing tests would help too, but there's something
strangely satisfying about looking at output in a web browser.

### Implementation

It is small:

<code>
tile : TilingInstruction a -> Html a
tile instruction = 
    Html.div [] (List.map (viewRow instruction.view) (rows instruction))

viewRow : (Tile -> Html a) -> List Tile -> Html a
viewRow view tiles =
    Html.div [] (List.map view tiles)

rows : TilingInstruction a -> List (List Tile)
rows instruction =
    let rowRange = range instruction.origin.y instruction.rowCount
        columnRange = range instruction.origin.x instruction.columnCount
    in mapTwo Tile columnRange rowRange
    
range : Int -> Int -> List Int
range origin count = [origin..(origin + count - 1)]

mapTwo : (a -> b -> c) -> List a -> List b -> List (List c)
mapTwo f xs ys =
    List.map (\y -> List.map (\x -> (f x y)) xs) ys
</code>

Mostly the implementation is list functions, with a little bit of
arranging the results of `view` into appropriate `div`s. This makes me
feel like the choice of abstractions was either excellent, or too low;
only time will tell.

### A demonstration

<code>
import Html exposing (Html)
import Html.App as App

import Tiler exposing (TilingInstruction)

type alias Model = TilingInstruction Msg

type Msg = NoOp

describe : Tiler.Tile -> Html Msg
describe tile =
    Html.text ("(" ++ (toString tile.x) ++ ", " ++ (toString tile.y) ++ ")") 

model =
    TilingInstruction 3 5 (Tiler.Tile 3 5) describe

update : Msg -> Model -> Model
update message model = model

main = 
    App.beginnerProgram { model = model
                        , view = Tiler.tile
                        , update = update
                        }
</code>

The vast majority of this code is ceremonial - most of our view
function is already implemented in `Tiler`, so we just create a tile
view function that lets us know the co-ordinates of a given tile, so
we can quickly check that things are working. Our demo doesn't have
any events, so a single `NoOp` `Msg` type alias is all we'll need
there.
