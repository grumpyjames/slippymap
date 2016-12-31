### What is elm?

and why am I using it?

elm (it is _always_ a lowercase e, apologies, pedants and e e cummings
haters) is "a delightful language for reliable webapps", according to
[the official website](http://www.elm-lang.org).

For me, elm is the answer to the following series of questions:

1. Can't we write just reliable webapps in javascript?

Yes, but it is _hard_. `undefined` is not a `function`, we hear.

It's hard enough that a great deal of effort has been expended
creating build pipelines for javascript webapps to make things easier.

2. Wait, _build_ pipelines?

3. Isn't javascript interpreted?

4. If we're going to preprocess our javascript, why don't we write in
a language that compiles to javascript, but hates freedom less/kills
fewer kittens, etc?

5. What would we want that language to look like?

Author's note: A bucket list of language features was removed from
here. Suffice to say: elm is a good fit for me.

### So, about elm...

It's statically _and_ strongly typed. Moving between types must always be explicit, there is no coercion. 

It doesn't just prefer immutability - it requires it. Unless we start writing native modules, elm won't allow mutation _at all_.

How the hell do we write a webapp where anything changes, then? Well, elm isn't really just a language. It also provides an architecture (although I'd be more tempted to call it a runtime) and an excellent standard library.

### Behind the curtain: the elm architecture

elm grandly claims we can write a whole webapp with only four ingredients:

* a type, `Model`, representing the 'state' of our app. This is usually an [ADT](https://en.wikipedia.org/wiki/Abstract_data_type), but it could just be a `String`. We'll provide an initial value for this state, `initialModel`.
* another type, `Msg`, that defines what events our application will produce and react to.
* a function, `update: Msg -> Model -> Model`. Given an event and the current state, produce the new state.
* another function, `view: Model -> Html Msg`. Given this state, produce a `Html` view.

You'll note that the return type of `view` is parameterized by our event type. This means that our resulting `Html` has hooks within it to trigger 'Msg' events based on user interactions, like a mouse click.

Under the covers, elm is running an event loop something like this:

<pre><code>
var model = initialModel;
var currentView = view(initialModel);
applyToDom(currentView);
while (true) {
    var event = events.poll();
    model = update(event, model);
    var newView = view(model);
    applyDiffToDom(diff(currentView, newView));
    currentView = newView;
}
</code></pre>

I've represented that in terrible javascript pseudocode in the spirit
of comprehensibility. I suspect that in reality there is not a queue,
but a callback; this isn't going to be too important for this
discussion though. Events turn up in the queue when events that
trigger `Msg`s occur.

We've used some functions I haven't defined: `applyToDom`, `diff` and
`applyDiffToDom`. The first of these takes the elm representation of
our view and makes the DOM reflect it. The second, `diff` takes two
elm view representations and computes the differences between
them. The third, `applyDiffToDom` takes the resulting diff and applies
it to the real DOM.

Whence events? Well, the Html return type returned from view has event
sending attributes buried within
it. [This demo](https://guide.elm-lang.org/architecture/user_input/buttons.html)
from the official documentation is the easiest to follow example.

Convinced? Good. Let's build something with elm.
