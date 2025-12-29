const std = @import("std");

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const include = b.path("include");

    const module = b.createModule(.{
        .target = target,
        .optimize = optimize,
        .link_libcpp = true,
    });
    module.addIncludePath(include);
    module.addCSourceFiles(.{
        .root = b.path("src"),
        .files = &.{"source.cpp"},
        .flags = &CXXFLAGS,
    });

    const lib = b.addLibrary(.{ .name = "demo", .root_module = module });
    lib.installHeadersDirectory(include, "demo", .{ .include_extensions = &.{".hpp"} });
    b.installArtifact(lib);

    { // Test
        const test_step = b.step("test", "Run tests");

        const catch2_dep = b.dependency("catch2", .{ .target = target, .optimize = optimize });

        const test_mod = b.createModule(.{ .target = target, .optimize = optimize });
        const test_exe = b.addExecutable(.{ .name = "test_demo", .root_module = test_mod });

        test_mod.addCSourceFiles(.{
            .root = b.path("test"),
            .files = &.{"test.cpp"},
            .flags = &CXXFLAGS,
        });
        test_mod.linkLibrary(lib);
        test_mod.linkLibrary(catch2_dep.artifact("Catch2"));
        test_mod.linkLibrary(catch2_dep.artifact("Catch2WithMain"));
        test_step.dependOn(&b.addRunArtifact(test_exe).step);
    }
}

const CXXFLAGS = .{
    "--std=c++23",
    "-Wall",
    "-Wextra",
    "-Werror",
};
