# `build.zig` for Catch2

Provides a package to be used by the zig package manager for C++ programs.

## Status

Building with Zig `0.15` will be possible once this issue is resolved: [Build fails on clang 20](https://github.com/catchorg/Catch2/issues/2991)

| Refname   | Catch2 version | Zig `0.15.x` | Zig `0.14.x` | Zig `0.13.x` | Zig `0.12.x` |
|:----------|:---------------|:------------:|:------------:|:------------:|:------------:|
| `master`  | `v3.8.1`       | ❌           | ✅           | ❌           | ❌           |
| `3.8.0+1` | `v3.8.0`       | ❌           | ✅           | ❌           | ❌           |
| `3.8.0`   | `v3.8.0`       | ❌           | ❌           | ✅           | ✅           |
| `3.7.1+1` | `v3.7.1`       | ❌           | ❌           | ✅           | ✅           |

## Use

Add the dependency in your `build.zig.zon` by running the following command:
```bash
zig fetch --save git+https://github.com/allyourcodebase/catch2#master
```

Then, in your `build.zig`:
```zig
const catch2_dep = b.dependency("catch2", { .target = target, .optimize = optimize });
const catch2_lib = catch2_dep.artifact("Catch2");
const catch2_main = catch2_dep.artifact("Catch2WithMain");
// wherever needed:
exe.linkLibrary(catch2_lib);
exe.linkLibrary(catch2_main);
```

A complete usage demonstration is provided in the [example](example) directory
