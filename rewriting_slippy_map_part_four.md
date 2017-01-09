Let's recap.

We can render a fixed grid of map tiles. We can lazily load them. We
can even navigate a little bit, so long as we are prepared to only
ever move in units of tile.

Our next step is to cope with moving around in a finer grained unit
than the tile. We'll approach this in three parts:

1. Working out in what tile (and whereabouts within the tile) the centre is.
2. Rendering a fixed size map centred on a particular location.
3. Making the centre movable.

### X marks the spot.

We're going to have to do some fairly tedious calculations here.

First, we're going to need to translate latitude/longitude into a tile address.

Handily,
[OpenStreetMap](https://wiki.openstreetmap.org/wiki/Slippy_map_tilenames#Haskell)
provides two `Haskell` functions that translate very nicely into `elm`:

~~~~ {.haskell}

log = logBase e

lon2tilex : Float -> Float -> Float
lon2tilex zoom lon = 
    (lon + 180.0) / 360.0 * (2.0 ^ (toFloat (floor zoom))) 

lat2tiley : Float -> Float -> Float
lat2tiley zoom lat = 
    (1.0 - log( tan(lat * pi/180.0) + 1.0 / cos(lat * pi/180.0)) / pi) / 2.0 * (2.0 ^ (toFloat (floor zoom)))
~~~~

These functions take a zoom level, a latitude or longitude, and return
a floating point x or y tile co-ordinate. The integer part refers to
the tile's index, and the fractional part refers to the location
within the tile. Given our tiles are `256px` squares, We'll be
translating `4.25` as tile `4`, `64px` in.

~~~~ {.haskell}

type alias LatLn =
    { latitude: Float
    , longitude: Float
    }

type alias TileAddress =
    { tile: (Int, Int)
    , pixelWithinTile: (Int, Int)
    }

lookup : Int -> LatLn -> TileAddress
lookup zoom latln = 
    let zoomAsFloat = toFloat zoom
        (xTile, xPixel) = address <| lon2tilex zoomAsFloat latln.longitude
        (yTile, yPixel) = address <| lat2tiley zoomAsFloat latln.latitude
    in TileAddress (xTile, yTile) (xPixel, yPixel)

tileSize = 256

address : Float -> (Int, Int)
address tileFloat =
    let tileIndex = floor tileFloat
        pixel = floor <| tileSize * (tileFloat - (toFloat tileIndex))
    in (tileIndex, pixel)

~~~~

`address` would be improved if there were a nice function in elm to
get the fractional part of a floating point number, but afaics there
isn't one.

Let's test this with another simple demo. Given a well known centre
point, we should be able to render the tile that contains it, and an
indicator to show whereabouts in the tile the precise point is.

### First go - just render the relevant tile

~~~~ {.haskell}

model = 
    [ Place "Sydney Opera House" (LatLn -33.8568 151.2153)
    , Place "Statue of Liberty" (LatLn 40.6892 -74.0445)
    , Place "Eiffel Tower" (LatLn 48.8584 2.2945)
    ]

view : List Place -> Html Msg
view model =
    Html.div [] (List.map viewOnePlace model)

viewOnePlace : Place -> Html Msg
viewOnePlace p =
    let tileAddress = lookup 15 p.latln
        tileUrl = imageUrl tileAddress.tile
    in Html.div [] [titled p.name, image tileUrl]

titled: String -> Html Msg
titled name = Html.text name

image imageUrl = Html.img [src imageUrl] []
~~~~

This found one issue; latitude and longitude were confused in the
locator code.

With that fixed, we get the following [demo](demo-4.1.html); looks
like our landmarks are in the tile we'd expect.

### No, really, X will mark the spot in a minute

We fight with CSS for a bit, then come up with the following:

~~~~ {.haskell}
viewOnePlace : Place -> Html Msg
viewOnePlace p =
    let tileAddress = lookup 15 p.latln
        tileUrl = imageUrl tileAddress.tile
    in Html.div [] [titled p.name, Html.div [] [image tileUrl, markTheSpot tileAddress.pixelWithinTile]]

image imageUrl = 
    let styles = style [("position", "relative"), ("z-index", "0")]
    in Html.img [styles, src imageUrl] []

px : Int -> String
px i = toString i ++ "px"

markTheSpot : (Int, Int) -> Html Msg
markTheSpot (x, y) = 
    let txt = Html.text "X"
        styles = style [ ("position", "relative")
                       , ("z-index", "1")
                       , ("top", (px (y - 265)))
                       , ("left", (px (x - 9)))]
    in Html.div [styles] [txt]
~~~~

We've guessed that a div with just 'X' in it puts the intersection of
the X around 9x9px into that div. We also subtract tile size from the
'top' co-ordinate, because it works.

It looks [like this](demo-4.2.html). Let's agree that those Xs are in
the right place, and move on.
