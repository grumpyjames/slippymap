### Making the centre movable

This...is going to be the fun bit.

### The prestige

It's _already_ movable.

Remember our model definition from [part five](five.html)?

~~~~ {.haskell}
type alias Model = 
    { location: LatLn
    , x: Int
    , y: Int
    , images : Dict (Int, Int) Url
    }
~~~~

You can think of the state of any elm application as a sequence of
`model` values. All we need to do is plumb in an event that can change
the location.

Let's do that in a really simple way to illustrate.

We've seen these places before:

~~~~ {.haskell}

type alias Place = 
    { name: String
    , latln: LatLn  
    }

places = 
    [ Place "Sydney Opera House" (LatLn -33.8568 151.2153)
    , Place "Statue of Liberty" (LatLn 40.6892 -74.0445)
    , Place "Eiffel Tower" (LatLn 48.8584 2.2945)
    ]

~~~~

Now let's move to them. Or warp to them, rather. We're not going to
try and animate anything just yet.

~~~~ {.haskell}
type Msg 
    = Complete (Int, Int) Url
    | Goto LatLn

update : Msg -> Model -> Model
update message model = 
    case message of
      Complete key url ->
          { model | images = Dict.insert key url model.images }
      Goto latln ->
          { model | location = latln }
~~~~

Finally, let's make it easy to move around:

~~~~ {.haskell}
buttons : Html Msg
buttons = 
    let button = \place -> Html.button [Events.onClick (Goto place.latln)] [Html.text place.name] 
    in Html.div [] (List.map button places)

view : Model -> Html Msg
view model = 
    let map = mapView model
    in Html.div [] [ buttons, map ]
~~~~

...and we're done. Demo [here](demo-6.1.html)
