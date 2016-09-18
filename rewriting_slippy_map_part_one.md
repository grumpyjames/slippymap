### Previously, on misguided elm experiments:

I wrote a mapping library! Why? Because interop is always a pain, and
I wanted to write an elm application that was heavily dependent on
geographic data.

At the time, I got the implementation to 'good enough' and then got on
with writing the app. In case anyone was interested, I stuck a
[demo](http://grumpyjames.github.io/) on the internet and left a link
on the elm mailing list. A great lack of interest followed.

A year or so later, I find myself again wanting an elm map layer. Elm
has moved quite a long way in that time though, and all the horrible
hacks I used to get things working in 0.15 are now long gone. In
addition, I distinctly remember some odd rendering issues in the
initial implementation.

### Time for a rewrite

Let's start by fixing the most annoying issue I can find in the
original implementation. When moving across the map, when a tile is
slow to load, the previous tile continues to be shown.

This is obvious, in retrospect. What the runtime will end up doing in
the original implementation is reusing the same image tags in the DOM,
but updating their 'src' attribute. It's only natural that the browser
continues to show the previous src until the new one is loaded.

### Step one: a simple proof on concept

The problem here is one of state. Elm will helpfully force us to be
explicit about it. Let's consider a much simpler case than a movable
tiled map, and just consider the problem of lazily showing a loaded
image.

Here's the representation of our state:

<code>

type alias Url = String

type LazyImage = Loading Url
               | Ready Url

type alias Model =
    List LazyImage

</code>

Here are the events we expect to be dealing with, and how we'll update
our state based on them. This is a very simple declaration; the only
event we'll be sending lets us know that a particular url has finished
loading.

<code>
type Msg = Complete Url
</code>

Here's how we'll update our model - when a 'Complete' event, arrives,
we'll update any `Loading` image that matches that url to be `Ready`.

<code>
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
</code>

...and here's how we'll render our state. The parts to show the ready
images are simple enough:

<code>
view : Model -> Html Msg
view model = 
    let f lazyImage =
        case lazyImage of
          Ready url -> readyImage url
          Loading url -> loadingImage url
    in node "div" [] (map f model)

readyImage : Url -> Html Msg
readyImage url =
    let attrs = [ src url, style [ ( "float", "left" ) ] ]
    in img attrs [] 
</code>

...it's only when we deal with the loading images that things get a
little crafty. We choose to generate two `img` tags. Only the first, a
loading gif, is visible. We cunningly keep the real image right next
to it, but don't display it. Finally, we hook into that image's `load`
event, converting it into an event that our elm application can
understand.

<code>
loadingImage : Url -> Html Msg
loadingImage url =
    let 
        loadingGifAttrs = 
            [ src "loading.gif"
            , style [ ( "float", "left" ) ]
            ]
        loadingImageAttrs = 
            [ src url
            , style [ ("display", "none" ) ]
            , onWithOptions "load" (Options False False) (succeed (Complete url))
            ]
    in node "div" [] [(img loadingGifAttrs []), (img loadingImageAttrs [])]
</code>

Finally, we tie together our model, events and view into an application:

<code>
main =
  App.beginnerProgram { model = model, view = view, update = update }
</code>

...and we're done. Next time, we'll break off another piece we'll need
to rebuild: a tiling function.
