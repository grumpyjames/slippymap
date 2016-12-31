# aim : build each blog post and each demonstration such that the results can be uploaded somewhere and shown.

# let's start just by manually markdowning in blogpost, and compiling the demonstrations.

function to_html()
{
    markdown < $1 > build/tmp.html
    cat header.html build/tmp.html footer.html > build/$2
}

to_html "index.md" "index.html"
mkdir -p build
to_html "what_is_elm.md" "zero.html"
to_html "rewriting_slippy_map_part_one.md" "one.html"
elm-make src/LazyLoaderDemo.elm --output build/demo-1.html
cp loading.gif build/
to_html "rewriting_slippy_map_part_two.md" "two.html"
elm-make src/TilerDemo.elm --output build/demo-2.1.html
to_html "rewriting_slippy_map_part_three.md" "three.html"
elm-make src/MapTilerDemo.elm --output build/demo-3.1.html
cp old-and-bad.html build/old-and-bad.html
cp old-and-bad.js build/old-and-bad.js
