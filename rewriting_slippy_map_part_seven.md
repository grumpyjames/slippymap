### Obvious Problem #1 - The world isn't flat.

We've conveniently neglected a couple of issues; at extremes of
East/West and at extremes of North/South.

In this post, we'll look at fixing the East/West issue. Next time
we'll look at North/South.

After that, we'll think carefully about our tile cache, and worry that
when we start zooming, we're going to hit trouble.

### Dealing with extremes of longitude

Wrapping at the East/West boundary is actually pretty simple - at zoom
`z`, the web mercator tiling is `2^z` tiles square. Wrapping at the
boundary could be as simple as adding a `% (2 ^ tile.zoom)` next to
`tile.x` when we transform our tile into a `URL`.

Bundling that logic into the `view` seems a bit of a hack though;
it'll probably break the tile cache as well. It would be better to
build the understanding of wrapping into 'Tile' itself.

~~~~ {.haskell}

-type alias Tile =
+type Tile =
+    ValidTile Int Int Int

~~~~

We swap our `type alias`ed Tile for a full blown ADT. We _won't_
expose its constructors, though. How will we construct a `Tile` then?

~~~~ {.haskell}

newTile : TileSpec -> Tile
newTile tileSpec =
    let wrap z c = c % (2 ^ z)
    in ValidTile (wrap tileSpec.zoom tileSpec.x) tileSpec.y tileSpec.zoom

~~~~

At the moment, the only valid condition we know about is to make sure
that our tile's `x` co-ordinate. In order to create tiles we're going
to force everyone through this new function that does the wrapping for
us.

We create a `type alias` that looks very much like the old `Tile` to
make the change a bit easier. We also provide:

~~~~ {.haskell}
fold : Tile -> (Int -> Int -> Int -> a) -> a
fold t f =
    case t of ValidTile x y z -> f x y z
~~~~

...what the hell is that, though? Well, _usually_ we'd let `Tile`'s
constructor out and let folk pattern match on it. Unfortunately this
also gives out the ability to construct `ValidTile`s to all and
sundry.

Instead, fold provides a way for outsiders to access the parts of
`ValidTile` without knowing about the constructor itself. If and when
we add a second species of `Tile` (it won't be long), we'll probably
create type aliases for each of the 'inner' types.

After a couple of minutes of fixing up compile errors, we're done. A
demonstration is all that is required now. Let's try and be little
cooler than just rendering a viewport near Fiji - let's go on a round
the world trip instead.

### Around the world in nine seconds

Let's boldly claim we're no longer beginners. Yes, that's right, it's
time to graduate to using
[`Html.program`](http://package.elm-lang.org/packages/elm-lang/html/2.0.0/Html#program). Why?
Because we're going to want to use the time in our program, and that
means using subscriptions.

~~~~ {.haskell}

# from Time's docs:
every : Time -> (Time -> msg) -> Sub msg

# in our application:
subs : Model -> Sub Msg
subs m = Time.every (25 * millisecond) Tick

main =
    App.program 
           { init = (model, Cmd.none)
           , update = update
           , subscriptions = subs
           , view = view
           }

~~~~

`program` parcels up some subscriptions to add to the events that our
Html (from `view`) is allowed to send. In this case, we're going to
inform elm that we'd like a `Tick` event every twenty five
milliseconds. We also gain the ability to send `elm` `Cmd`s from our
update function and our initial model. Not only that, but our
subscriptions are not a constant - they can change based on the value
of our model.

We're keeping it simple, and only having a single, permanent
subscription. No further commands are added.

What will we do with our tick, then?

~~~~ {.haskell}

update : Msg -> Model -> (Model, Cmd Msg)
update message model = 
    case message of
      Complete key url ->
          ( { model | images = Dict.insert key url model.images }, Cmd.none )
      Tick time ->
          ( { model | location = rotateOneDegree model.location }, Cmd.none )

rotateOneDegree : LatLn -> LatLn
rotateOneDegree latln = 
    let newLongitude = latln.longitude + 1
    in LatLn latln.latitude newLongitude 

~~~~

The tile locator functions are written in terms of appropriately
periodic functions such that we can happily forget about keeping our
longitude within `(-180, 180)`.

[Here](demo-7.1.html) is the demo. Hypnotic, isn't it.
