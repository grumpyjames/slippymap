# aim : build each blog post and each demonstration such that the results can be uploaded somewhere and shown.

# let's start just by manually markdowning in blogpost, and compiling the demonstrations.

mkdir -p build
markdown < rewriting_slippy_map_part_one.md > build/one.html
elm-make src/LazyLoaderDemo.elm --output build/demo-1.html
cp loading.gif build/
markdown < rewriting_slippy_map_part_two.md > build/two.html
elm-make src/TilerDemo.elm --output build/demo-2.1.html
elm-make src/MapTilerDemo.elm --output build/demo-2.2.html
