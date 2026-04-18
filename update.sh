#!/bin/bash
# Parameter: New Catch2 version, without the v prefix, e.g. "3.14.0"
set -euo pipefail

VERSION=$1
URL="https://github.com/catchorg/Catch2"
GIT_REF="v$VERSION"
FETCH_ARG="git+$URL#$GIT_REF"

# 1. Fetch the new version
HASH=$(zig fetch $FETCH_ARG)
zig fetch --save=upstream $FETCH_ARG

# 2. Re-generate the file lists
cat zig-pkg/$HASH/{src/catch2,tests}/meson.build | zig run generate.zig | zig fmt --stdin > generated.zig

# 3. Bump the package version
sed "s|\([.]version *= *\).*|\1\"$VERSION\",|" build.zig.zon > tmp.zon
mv tmp.zon build.zig.zon
