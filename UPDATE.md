# Update procedure

Bumping the upstream version involves:
1. Fetching the new version
2. Re-generating [generated.zig](generated.zig)
3. Bumping the package version in [build.zig.zon](build.zig.zon)

[generate.zig](generate.zig) requires Zig `0.16`

```shell
VERSION="v3.14.0"
URL="https://github.com/catchorg/Catch2"

FETCH_ARG="git+$URL#$VERSION"
HASH=$(zig fetch $FETCH_ARG)
zig fetch --save=upstream $FETCH_ARG
cat zig-pkg/$HASH/{src/catch2,tests}/meson.build | zig run generate.zig | zig fmt --stdin > generated.zig
```

Note that for now the generate script is not called from `build.zig`, to keep `build.zig` compatible with older zig versions.
