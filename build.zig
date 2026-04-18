const std = @import("std");
const gen = @import("generated.zig");

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const add_prefix = b.option(bool, "add-prefix", "Prefix all macros with CATCH_") orelse false;
    const console_width = b.option(u32, "console-width", "Number of columns in the output: affects line wraps. (Defaults to 80)") orelse 80;
    const fast_compile = b.option(bool, "fast-compile", "Sacrifices some (rather minor) features for compilation speed") orelse false;
    const disable = b.option(bool, "disable", "Disables assertions and test case registration") orelse false;
    const default_reporter = b.option([]const u8, "default-reporter", "Choose the reporter to use when it is not specified via the --reporter option. (Defaults to 'console')") orelse "console";

    const upstream = b.dependency("upstream", .{});

    const config = b.addConfigHeader(
        .{
            .style = .{ .cmake = upstream.path("src/catch2/catch_user_config.hpp.in") },
            .include_path = "catch2/catch_user_config.hpp",
        },
        .{
            .CATCH_CONFIG_PREFIX_ALL = add_prefix,
            .CATCH_CONFIG_CONSOLE_WIDTH = console_width,
            .CATCH_CONFIG_FAST_COMPILE = fast_compile,
            .CATCH_CONFIG_DISABLE = disable,
            .CATCH_CONFIG_DEFAULT_REPORTER = default_reporter,
            .CATCH_CONFIG_FALLBACK_STRINGIFIER = null,
        },
    );

    const catch2 = b.addLibrary(.{
        .name = "Catch2",
        .root_module = b.createModule(.{
            .target = target,
            .optimize = optimize,
            .link_libcpp = true,
        }),
    });
    catch2.root_module.addCSourceFiles(.{
        .root = upstream.path("src/catch2"),
        .files = &(gen.internal_sources ++ gen.reporter_sources ++ gen.benchmark_sources),
        .flags = &CXXFLAGS,
    });
    catch2.installConfigHeader(config);
    catch2.installHeadersDirectory(upstream.path("src"), "", .{
        .include_extensions = &.{".hpp"},
    });

    const with_main = b.addLibrary(.{
        .name = "Catch2WithMain",
        .root_module = b.createModule(.{
            .target = target,
            .optimize = optimize,
            .link_libcpp = true,
        }),
    });
    with_main.root_module.addCSourceFile(.{
        .file = upstream.path("src/catch2/internal/catch_main.cpp"),
        .flags = &CXXFLAGS,
    });

    const libs: []const *std.Build.Step.Compile = &.{ catch2, with_main };
    for (libs) |lib| {
        lib.root_module.addIncludePath(upstream.path("src"));
        lib.root_module.addConfigHeader(config);
        b.installArtifact(lib);
    }

    { // Testing
        const test_step = b.step("test", "Run tests");
        const test_exe = b.addExecutable(.{
            .name = "SelfTest",
            .root_module = b.createModule(.{
                .target = target,
                .optimize = optimize,
                .link_libcpp = true,
            }),
        });
        test_exe.root_module.addIncludePath(upstream.path("tests/SelfTest"));
        test_exe.root_module.addCSourceFiles(.{
            .root = upstream.path("tests"),
            .files = &gen.self_test_sources,
            .flags = &CXXFLAGS,
        });
        test_exe.root_module.linkLibrary(catch2);
        test_exe.root_module.linkLibrary(with_main);
        test_step.dependOn(&b.addRunArtifact(test_exe).step);
    }
}

const CXXFLAGS = .{
    "--std=c++23",
    "-Wall",
    "-Wextra",
    "-Werror",
};
