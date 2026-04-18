# `build.zig` for Catch2

Provides a package to be used by the zig package manager for C++ programs.

## Status

| Refname   | Catch2 version | Zig `0.16.x` | Zig `0.15.x` | Zig `0.14.x` | Zig `0.13.x` | Zig `0.12.x` |
|:----------|:---------------|:------------:|:------------:|:------------:|:------------:|:------------:|
| `3.14.0`  | `v3.14.0`      | ✔            | ✔            | ✅           | ❌           | ❌           |
| `3.8.0`   | `v3.8.0`       | ❌           | ❌           | ❌           | ✅           | ✅           |

✔ means that that the package is compatible but that Catch2's own tests fail because of [a regression of LLVM 20](https://github.com/llvm/llvm-project/issues/140519).
The error occurs when using `TEMPLATE_PRODUCT_TEST_CASE`: [Build failure with clang++ 20](https://github.com/catchorg/Catch2/issues/2991). If you don't use this macro you should be fine.

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

## Options

```
  -Dadd-prefix=[bool]          Prefix all macros with CATCH_
  -Dconsole-width=[int]        Number of columns in the output: affects line wraps. (Defaults to 80)
  -Dfast-compile=[bool]        Sacrifices some (rather minor) features for compilation speed
  -Ddisable=[bool]             Disables assertions and test case registration
  -Ddefault-reporter=[string]  Choose the reporter to use when it is not specified via the --reporter option. (Defaults to 'console')
```
