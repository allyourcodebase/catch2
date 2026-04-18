# Update procedure

Bumping the upstream version involves:
1. Fetching the new version
2. Re-generating [generated.zig](generated.zig)
3. Bumping the package version in [build.zig.zon](build.zig.zon)

[generate.zig](generate.zig) requires Zig `0.16`

Note that for now the `generate.zig` script is not called from `build.zig`, to keep `build.zig` compatible with older zig versions.

```shell
./update.sh 3.14.0
```
