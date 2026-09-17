#!/bin/sh
# UMS V1 - a preview per shipped part. Needs a display; xvfb-run supplies one.
set -e
mkdir -p docs/previews
for f in dist/stl/*.stl; do
    n=$(basename "$f" .stl)
    printf 'import("%s/%s");\n' "$(pwd)" "$f" > /tmp/ums_preview.scad
    xvfb-run -a openscad -o "docs/previews/$n.png" --render --imgsize=620,760 \
        --colorscheme=Tomorrow --autocenter --viewall --camera=0,0,0,68,0,200,0 \
        /tmp/ums_preview.scad >/dev/null 2>&1
    echo "  $n"
done
