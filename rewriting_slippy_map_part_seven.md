### Problems

We've conveniently neglected a couple of issues.

To enumerate the ones I have noticed:

- What if someone gives us an interesting location?
  Like the North pole.
  Or somewhere at one hundred and eighty degrees West or East?
- We leak memory the more map tiles we've shown
  This is going to be a nightmare when we start varying the zoom level

Let's fix these issues before we go any further.

### Dealing with interesting locations.

Wrapping at the East/West boundary is actually pretty simple.

