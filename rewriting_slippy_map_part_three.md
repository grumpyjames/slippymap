### Combining two ideas

Previously, we wrote a lazy image loader, and a very simple tiling
function. Now we want to combine them.

Our goal is to render a tiling of web mercator images, with each image
being lazily loaded. Imagine the previous tiling demo, but instead of
rendering the tile's coordinate we lazily load the equivalent map tile
corresponding to that coordinate.

We'll also provide some basic controls so we can change the origin of
the resulting tiling.

Let's have a think about how to do this.

<pre><code>
type alias TilingInstruction a = 
    { rowCount: Int
    , columnCount: Int
    , origin: Tile
    , view: Tile -> Html a
    }
</code></pre>

It's clear that most of our change, from the previous demo, is going
to be in the implementation of `view`. We'll also hold on to a bit
more state in our model, which looks like this.

<pre><code>
type alias Model = 
    { rowCount: Int
    , columnCount: Int
    , origin: Tiler.Tile
    , loadedImages : Dict (Int, Int) Url
    }
</pre></code>

The events we're going to handle will also widen a little; we'll add
the co-ordinate of the tile to the 'image loaded' event, and we'll
also add an event to encapsulate a shift in the map's origin.

<pre><code>
type Msg = Complete (Int, Int) Url
         | Shift (Int, Int)
</pre></code>

Let's look at how we define our view.

<pre><code>
view : Model -> Html Msg
view m =
    let tiles = Tiler.tile (TilingInstruction m.rowCount m.columnCount m.origin (loadingTileImages m.loadedImages))
    in Html.div [] [controls, tiles]
</code></pre>

We'll have some controls, and some tiles. The tiles are the bit we're
interested in. We're invoking exactly the same `tile` function that
was introduced in part two, but this time, the instruction we are
passing it is slightly more dynamic.

The type of `view` in `TilingInstruction` is `Tile -> Html a`. It
looks like `loadingTileImages m.loadedImages`. is going to have to be
pretty clever.

<pre><code>
loadingTileImages : Dict (Int, Int) Url -> Tiler.Tile -> Html Msg
loadingTileImages cache tile =
    let lookup = Dict.get (tile.x, tile.y) cache
    in 
      case lookup of
        Just url -> readyImage url
        Nothing -> loadingImage (tile.x, tile.y) (imageUrl tile)
</code></pre>

...handily though, it is actually quite simple: we're _partially
applying_ this function, binding the loading images into place for
each invocation. At the point where the tiler requests a view for a
particular tile, we'll check to see if we've already loaded it, and
we'll pick a rendering based on that state.

Our definitions of `loadingImage` and `readyImage` are very similar to
the original `LazyLoader` demo with the following difference:

Before:
<pre><code>onWithOptions "load" (Options False False) (succeed (Complete url))</code></pre>

After:
<pre><code>onWithOptions "load" (Options False False) (succeed (Complete coordinate url))</code></pre>

This way, when the load event arrives, handling it is much simpler.

<pre><code>
update : Msg -> Model -> Model
update message model =
    case message of
      Complete key value ->
          { model | loadedImages = Dict.insert key value model.loadedImages }
</code></pre>

Very simple.

Adding the controls is...tedious but effective:

<pre><code>
controls : Html Msg
controls = 
    let shiftButton shift text = Html.button [(Html.Events.on "click" (succeed (Shift shift)))] [Html.text text]
        upButton = shiftButton (0, -1) "North"
        downButton = shiftButton (0, 1) "South"
        leftButton = shiftButton (-1, 0) "West"
        rightButton = shiftButton (1, 0) "East"
    in Html.div [] [upButton, downButton, leftButton, rightButton]
</code></pre>

...and handling the `Shift` messages this sends is again trivial,
here's the other half of our update function:

<pre><code>
      Shift diff -> 
          { model | origin = shift diff model.origin }

shift : (Int, Int) -> Tiler.Tile -> Tiler.Tile
shift (dx, dy) tile =
    Tiler.Tile (tile.x + dx) (tile.y + dy) 
</code></pre>

We'll provide a function, `imageUrl : Tiler.Tile -> Url`, that knows
how to craft a `URL` that corresponds to appropriate web mercator
tiles source from [MapBox](http://www.mapbox.com), and we'll have our
next demo.

Author's note: an extended battle with HTML/CSS followed here after
realising that this demo worked rather poorly on viewports with a
width smaller than 1024px. HTML/CSS won, so we're going to
have to do some more work.

To cut a long story short, the `div` that the `Tiler` creates to house
each row of tiles will need to be given an explicit width to prevent
non-fitting tile images from skipping on to the next line. Ugh.

### Widening `TilingInstruction`

<pre><code>
type alias TilingInstruction a = 
    { rowCount: Int
    , columnCount: Int
    , origin: Tile
    , viewTile: Tile -> Html a
    , viewRow: List (Html a) -> Html a
    }
</code></pre>

Previously, our `tile` function handily dropped our elements into
appropriate `div`s and we were done. Now we have to get each row's
`div` to have a fixed width, so we pass a row viewer, as well as a
tile viewer. We should probably think about whether `tile` really
wants to know about `Html` at some point, but this was the easiest way
to get things to work in any given browser window for this post.

Here's what our `view` function looks like now:

<pre><code>
view : Model -> Html Msg
view m =
    let tiles = 
            Tiler.tile { rowCount = m.rowCount
                       , columnCount = m.columnCount
                       , origin = m.origin
                       , viewTile = (loadingTileImages m.images)
                       , viewRow = fixedWidth
                       }
    in Html.div [] [controls, tiles]

px : Int -> String
px pixels = (toString pixels) ++ "px"

fixedWidth : List (Html a) -> Html a
fixedWidth htmls = 
    let width = (List.length htmls) * 256
    in Html.div [style [("width", (px width))]] htmls
</code></pre>

...and finally, here is the [demo](demo-3.1.html)
