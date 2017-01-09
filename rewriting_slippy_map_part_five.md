In the last post, we put together a simple application to render the
tile that contains a particular `LatLn`. We even drew an X over the
exact point to convince ourselves we'd got the maths right.

Now we're going to try for step 2:

### Render a fixed size map, centered on a given `LatLn`

The majority of this post is going to be some fairly arduous 2D
calculations. Bear with me.

#### Rendering a fixed sized map

Let's say that we want to have a map x pixels wide, and y pixels
high. We'll want to center it at (lat, ln).

We know that, in fact, we can only render a map that has height and
width as multiples of our tile size. We can then deploy some
`overflow: hidden` cunning so that the visible portion is exactly `x` by `y`.

To do that, we'll already have to render enough tiles such that:

~~~~
columnCount * tileSize > x
rowCount * tileSize > y
~~~~

This will work perfectly so long as the centre of the visible part of
our map is the centre of the whole tiling.

Why? Consider the pathological case, where `x = y = tileSize`, but the
desired centre is in one of the corners of the tile in question.

If we rendered only a single tile, moving any corner to the center
leaves three quarters of our `x` by `y` area blank.

We could, if we knew the corner in advance, render a 2x2 grid. Given
we're going to be moving the centre around at some point in future,
let's not do that.

So we need at least

~~~~
columnCount = (x // tileSize) + 2
rowCount = (y // tileSize) + 2
~~~~

Here `//` is integer division, e.g `5 // 2 = 2`

We're not done, sadly. Imagine a case where `columnCount` ends up being
even. The smallest such number we can get with the above equation is
`4`; the largest such `x` that could produce this `columnCount` is 767.

Our centre tile must be in the second or third column, i.e its
horizontal co-ordinate is somewhere in `[256, 768]`. We will have to
place it at visible horizontal co-ordinate `383`, so there must always
be at least that number of pixels either side of it.

This means our grid should really contain all the horizontal
co-ordinates in `[-127, 1151]`, which is wider than the `[0, 1024]` we
have using four tile rows. `127 + (1151 - 1024) = 254` tells us we
will need one more tile.

Let's go for

~~~~
columnCount = (x // tileSize) + 3
rowCount = (y // tileSize) + 3
~~~~

So, given a request for a visible map later that is `x` by `y`, we
know how big the render area needs to be, and how many tiles it will
need to be made up of.

How will we make it so that the requested centre is in the middle of
the visible portion, though?

#### Controlling the visible layer's centre

Our visible portion is `x` by `y`. In any sensible co-ordinate system,
we want our chosen `LatLn` to be rendered at `(x / 2, y / 2)`.

Our rendering layer is actually `tileSize * ((x // tileSize) + 3)` by
`tileSize * ((y // tileSize) + 3)`.

Let's imagine a perfect world, where our `LatLn` magically turns out
as the centre of its central tile (or the apex of the four centre
tiles should there be no canonical centre tile).

Here's a terrible ASCII representation of that state of affairs:

~~~~
______________________________________________
| invisible portion                          |
|    ___________________________________     |
|    |                                 |     |
|    |  visible portion                |     |
|    |                                 |     |
|    |                                 |     |
|    |_________________________________|     |
|                                            | 
|____________________________________________| 
~~~~

If both portions were visible, we'd achieve this with padding, with:

~~~~
padding-top = padding-bottom =
    (invisible height - visible height) / 2 =
        (tileSize * ((y // tileSize) + 3) - y) / 2 

padding-left = padding-right =
    (invisible width - visible width) / 2 =
        (tileSize * ((x // tileSize) + 3) - x) / 2 
~~~~

We'll probably have to do this with some `position: absolute`, so in
fact we'll probably provide:

~~~~

invisible-top = - ((tileSize * ((y // tileSize) + 3) - y) / 2) 
invisible-left = - ((tileSize * ((x // tileSize) + 3) - x) / 2)

~~~~

This already seems non-trivial, and it's about to get worse: our
`LatLn` is almost never going to be this well behaved for us.

Have a pause and think about how we might do this before
continuing.

I got to an answer by thinking about the following question:

Let's consider the coordinates of our `LatLn` in the _invisible_
portion. This is just going to be a simple `m` by `n` grid of
tiles. Which tile will our `LatLn` be in?

Let's consider this in only the `m` dimension (everything so far has been
symmetric, I reckon we can do this WLOG).

If `m` is odd, the centre is in the `m // 2 + 1`th tile.  If `m` is
even - well, hmm - we have to choose, I guess. Let's choose to always
put it in the `m // 2 + 1`th tile once again.

We now know that `LatLn` is in the `(m // 2 + 1, n // 2 + 1)`th
tile. We know how big tiles are, and we know (from the
`pixelWithinTile` part of the calculated `TileAddress`) the location
of `LatLn` within that tile.

We can now calculate the coordinates of `LatLn` within the grid. Once
again, we're going to choose the top left of our plane as (0,0), with
right and down being the positive directions. Sorry again, maths folk.

~~~~

tileAddress = lookup zoom latln
(xPixel, yPixel) = tileAddress.pixelWithinTile

m = (x // tileSize) + 3
n = (y // tileSize) + 3

latlnx = ((m // 2) * tileSize) + xPixel
latlny = ((n // 2) * tileSize) + yPixel

~~~~

Now, all we need to do is calculate `top` and `left` such that:

~~~~

top = y // 2 - latlny
left = x // 2 - latlnx

~~~~

This _should_ centre our `LatLn` within the visible portion. Let's
translate this nonsense into `elm` to see if it works.

First, we extract out the lazy grid loader from part three. We let it
own the event type it sends to avoid coupling our new demo and part
three's demo together.

~~~~ {.haskell}

type alias ImageLoaded =
    { coordinate: (Int, Int)
    , url: Url
    }

loadingTileImages : Dict (Int, Int) Url -> Tiler.Tile -> Html ImageLoaded

~~~~

See [part three](three.html) for the full details thereof.

Here's most of our app:

~~~~ {.haskell}
type alias Model = 
    { location: LatLn
    , x: Int
    , y: Int
    , images : Dict (Int, Int) Url
    }

model = Model (LatLn 48.858193 2.2940533) 712 466 Dict.empty

type Msg = Complete (Int, Int) Url

update : Msg -> Model -> Model
update message model = 
    case message of
      Complete key url ->
          { model | images = Dict.insert key url model.images }

view : Model -> Html Msg
view model = 
    let zoom = 15
        tileSize = 256
        (columnCount, rowCount) = calculateTileCount tileSize (model.x, model.y)
        tileAddress = lookup 15 model.location
        (centreTx, centreTy) = tileAddress.tile
        (left, top) = calculateOffsets tileSize (model.x, model.y) (columnCount, rowCount) tileAddress.pixelWithinTile
        tiles = Tiler.tile { rowCount = rowCount
                           , columnCount = columnCount
                           , origin = Tiler.Tile (centreTx - (columnCount // 2)) (centreTy - (rowCount // 2)) zoom
                           , viewTile = (loadingTileImages model.images)
                           , viewRow = fixedWidth tileSize
                           , outerAttributes = [ style [("position", "relative"), ("top", px top), ("left", px left)] ]
                           }
        lift = \imageLoaded -> Complete imageLoaded.coordinate imageLoaded.url
    in Html.div [ style [("width", px model.x), ("height", px model.y), ("overflow", "hidden")] ] [ App.map lift tiles ]
~~~~

`App.map lift tiles` is helping us convert `LazyTiles`'s `ImageLoaded`
type into our own `Msg` type.

We quietly added `zoom` as a parameter to Tiler.Tile somewhere in this
change; we're going to need it later, and having it hardcoded deep
down in the image url factory was making the author unhappy.

In two helper functions we can see the calculations we outlined
earlier:

~~~~ {.haskell}
calculateTileCount : Int -> (Int, Int) -> (Int, Int)
calculateTileCount tileSize (x, y) =
    ((x // tileSize) + 3, (y // tileSize) + 3)

calculateOffsets : Int -> (Int, Int) -> (Int, Int) -> (Int, Int) -> (Int, Int)
calculateOffsets tileSize (x, y) (columnCount, rowCount) (xpixel, ypixel) =
    let xoff = (columnCount // 2) * tileSize
        yoff = (rowCount // 2) * tileSize
    in
    ( (x // 2) - (xoff + xpixel)
    , (y // 2) - (yoff + ypixel)
    )
~~~~

We might consider reworking `calculateOffsets` to take a type alias
instead - it was quite tricky making sure each of those tuples was in
the right place.

[The resulting demo](demo-5.1.html) should be centred on the Eiffel Tower.
