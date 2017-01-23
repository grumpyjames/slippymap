## elm

I've been playing with elm as a frontend language since 0.14. I've
written some terrible code, but I've learned quite a lot.

One thing I have not found is a library that allows easy elm
interaction with mapping applications. Most of the side projects I
start involve some element of geolocation, so I often want to be able
to render an interactive map.

I've done this, badly, once. This series of posts will attempt to
document a second attempt, which will hopefully end a little better.

### Notes

I started working on this using elm 0.17.1, and I am slow; we'll probably suffer from one or two migrations. Effort will be made to keep the whole series of posts up to date, but my commitment to this bit of exposition is likely to be lackadaisical, so apologies in advance if elm is now v1.0 and the code hasn't changed since 2016...

You should always be able find the latest code, including the markdown source for the posts, [here](https://github.com/grumpyjames/slippymap). Pull requests for errors eagerly sought.

### Without further ado

The content, in `n` parts

0. [What is elm?](zero.html)
1. [A lazy image loader](one.html)
2. [A tiling function](two.html)
3. [Composing 1 and 2: Lazily loading a tiled map](three.html)
4. [X marks the spot: Starting to centre the map](four.html)
5. [Rendering a fixed viewport centred at latln](five.html)
6. [The centre cannot hold - let's move it](six.html)
