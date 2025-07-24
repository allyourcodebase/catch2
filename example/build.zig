const std = @import("std");

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const include = b.path("include");

    const lib = b.addLibrary(.{
        .name = "demo",
        .root_module = b.createModule(.{ .target = target, .optimize = optimize }),
    });
    lib.addIncludePath(include);
    lib.addCSourceFiles(.{
        .root = b.path("src"),
        .files = &.{"source.cpp"},
        .flags = &CXXFLAGS,
    });
    lib.linkLibCpp();
    lib.installHeadersDirectory(include, "demo", .{ .include_extensions = &.{".hpp"} });
    b.installArtifact(lib);

    { // Test
        const test_step = b.step("test", "Run tests");
        const test_exe = b.addExecutable(.{
            .name = "test_demo",
            .root_module = b.createModule(.{ .target = target, .optimize = optimize }),
        });
        const run_test = b.addRunArtifact(test_exe);

        const catch2_dep = b.dependency("catch2", .{ .target = target, .optimize = optimize });
        const catch2_lib = catch2_dep.artifact("Catch2");
        const catch2_main = catch2_dep.artifact("Catch2WithMain");

        test_exe.addCSourceFiles(.{ .root = b.path("test"), .files = &.{"test.cpp"}, .flags = &CXXFLAGS });
        test_exe.linkLibrary(lib);
        test_exe.linkLibrary(catch2_lib);
        test_exe.linkLibrary(catch2_main);
        test_step.dependOn(&run_test.step);
    }
}

const CXXFLAGS = .{
    "--std=c++23",
    "-Wall",
    "-Wextra",
    "-Werror",
};
