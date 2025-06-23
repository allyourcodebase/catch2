const std = @import("std");

const version = .{ .major = 3, .minor = 8, .patch = 1 };

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const upstream = b.dependency("upstream", .{ .target = target, .optimize = optimize });

    const add_prefix = b.option(bool, "add-prefix", "Prefix all macros with CATCH_") orelse false;
    const console_width = b.option(u32, "console-width", "Number of columns in the output: affects line wraps. (Defaults to 80)") orelse 80;
    const fast_compile = b.option(bool, "fast-compile", "Sacrifices some (rather minor) features for compilation speed") orelse false;
    const disable = b.option(bool, "disable", "Disables assertions and test case registration") orelse false;
    const default_reporter = b.option([]const u8, "default-reporter", "Choose the reporter to use when it is not specified via the --reporter option. (Defaults to 'console')") orelse "console";

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

    const catch2 = b.addStaticLibrary(.{ .name = "Catch2", .target = target, .optimize = optimize });
    catch2.addCSourceFiles(.{
        .root = upstream.path("src/catch2"),
        .files = &source_files,
        .flags = &CXXFLAGS,
    });
    catch2.installConfigHeader(config);
    catch2.installHeadersDirectory(upstream.path("src"), "", .{ .include_extensions = &.{".hpp"} });

    const with_main = b.addStaticLibrary(.{ .name = "Catch2WithMain", .target = target, .optimize = optimize });
    with_main.addCSourceFiles(.{
        .root = upstream.path("src/catch2/internal"),
        .files = &.{"catch_main.cpp"},
        .flags = &CXXFLAGS,
    });

    const test_step = b.step("test", "Run tests");
    const test_exe = b.addExecutable(.{ .name = "SelfTest", .target = target, .optimize = optimize });
    test_exe.addIncludePath(upstream.path("tests/SelfTest"));
    test_exe.addCSourceFiles(.{ .root = upstream.path("tests/SelfTest"), .files = &test_files, .flags = &CXXFLAGS });
    test_exe.linkLibCpp();
    const run_test = b.addRunArtifact(test_exe);
    test_step.dependOn(&run_test.step);

    const libs = [_]*std.Build.Step.Compile{ catch2, with_main };
    for (libs) |lib| {
        lib.linkLibCpp();
        lib.addIncludePath(upstream.path("src"));
        lib.addConfigHeader(config);
        b.installArtifact(lib);
        test_exe.linkLibrary(lib);
    }
}

const CXXFLAGS = .{
    "--std=c++20",
    "-Wall",
    "-Wextra",
    "-Werror",
};

const source_files = .{
    "benchmark/catch_chronometer.cpp",
    "benchmark/detail/catch_analyse.cpp",
    "benchmark/detail/catch_benchmark_function.cpp",
    "benchmark/detail/catch_run_for_at_least.cpp",
    "benchmark/detail/catch_stats.cpp",

    "catch_approx.cpp",
    "catch_assertion_result.cpp",
    "catch_config.cpp",
    "catch_get_random_seed.cpp",
    "catch_message.cpp",
    "catch_registry_hub.cpp",
    "catch_session.cpp",
    "catch_tag_alias_autoregistrar.cpp",
    "catch_test_case_info.cpp",
    "catch_test_spec.cpp",
    "catch_timer.cpp",
    "catch_tostring.cpp",
    "catch_totals.cpp",
    "catch_translate_exception.cpp",
    "catch_version.cpp",
    "internal/catch_assertion_handler.cpp",
    "internal/catch_case_insensitive_comparisons.cpp",
    "internal/catch_clara.cpp",
    "internal/catch_commandline.cpp",
    "internal/catch_console_colour.cpp",
    "internal/catch_context.cpp",
    "internal/catch_debug_console.cpp",
    "internal/catch_debugger.cpp",
    "internal/catch_decomposer.cpp",
    "internal/catch_enforce.cpp",
    "internal/catch_enum_values_registry.cpp",
    "internal/catch_errno_guard.cpp",
    "internal/catch_exception_translator_registry.cpp",
    "internal/catch_fatal_condition_handler.cpp",
    "internal/catch_floating_point_helpers.cpp",
    "internal/catch_getenv.cpp",
    "internal/catch_istream.cpp",
    "internal/catch_jsonwriter.cpp",
    "internal/catch_lazy_expr.cpp",
    "internal/catch_leak_detector.cpp",
    "internal/catch_list.cpp",
    "internal/catch_message_info.cpp",
    "internal/catch_output_redirect.cpp",
    "internal/catch_parse_numbers.cpp",
    "internal/catch_polyfills.cpp",
    "internal/catch_random_number_generator.cpp",
    "internal/catch_random_seed_generation.cpp",
    "internal/catch_reporter_registry.cpp",
    "internal/catch_reporter_spec_parser.cpp",
    "internal/catch_reusable_string_stream.cpp",
    "internal/catch_run_context.cpp",
    "internal/catch_section.cpp",
    "internal/catch_singletons.cpp",
    "internal/catch_source_line_info.cpp",
    "internal/catch_startup_exception_registry.cpp",
    "internal/catch_stdstreams.cpp",
    "internal/catch_string_manip.cpp",
    "internal/catch_stringref.cpp",
    "internal/catch_tag_alias_registry.cpp",
    "internal/catch_test_case_info_hasher.cpp",
    "internal/catch_test_case_registry_impl.cpp",
    "internal/catch_test_case_tracker.cpp",
    "internal/catch_test_failure_exception.cpp",
    "internal/catch_test_registry.cpp",
    "internal/catch_test_spec_parser.cpp",
    "internal/catch_textflow.cpp",
    "internal/catch_uncaught_exceptions.cpp",
    "internal/catch_wildcard_pattern.cpp",
    "internal/catch_xmlwriter.cpp",

    "interfaces/catch_interfaces_capture.cpp",
    "interfaces/catch_interfaces_config.cpp",
    "interfaces/catch_interfaces_exception.cpp",
    "interfaces/catch_interfaces_generatortracker.cpp",
    "interfaces/catch_interfaces_registry_hub.cpp",
    "interfaces/catch_interfaces_reporter.cpp",
    "interfaces/catch_interfaces_reporter_factory.cpp",
    "interfaces/catch_interfaces_testcase.cpp",

    "generators/catch_generator_exception.cpp",
    "generators/catch_generators.cpp",
    "generators/catch_generators_random.cpp",

    "matchers/catch_matchers.cpp",
    "matchers/catch_matchers_container_properties.cpp",
    "matchers/catch_matchers_exception.cpp",
    "matchers/catch_matchers_floating_point.cpp",
    "matchers/catch_matchers_predicate.cpp",
    "matchers/catch_matchers_quantifiers.cpp",
    "matchers/catch_matchers_string.cpp",
    "matchers/catch_matchers_templated.cpp",
    "matchers/internal/catch_matchers_impl.cpp",

    "reporters/catch_reporter_automake.cpp",
    "reporters/catch_reporter_common_base.cpp",
    "reporters/catch_reporter_compact.cpp",
    "reporters/catch_reporter_console.cpp",
    "reporters/catch_reporter_cumulative_base.cpp",
    "reporters/catch_reporter_event_listener.cpp",
    "reporters/catch_reporter_helpers.cpp",
    "reporters/catch_reporter_json.cpp",
    "reporters/catch_reporter_junit.cpp",
    "reporters/catch_reporter_multi.cpp",
    "reporters/catch_reporter_registrars.cpp",
    "reporters/catch_reporter_sonarqube.cpp",
    "reporters/catch_reporter_streaming_base.cpp",
    "reporters/catch_reporter_tap.cpp",
    "reporters/catch_reporter_teamcity.cpp",
    "reporters/catch_reporter_xml.cpp",
};

const test_files = .{
    "TestRegistrations.cpp",
    "IntrospectiveTests/Algorithms.tests.cpp",
    "IntrospectiveTests/AssertionHandler.tests.cpp",
    "IntrospectiveTests/Clara.tests.cpp",
    "IntrospectiveTests/CmdLine.tests.cpp",
    "IntrospectiveTests/CmdLineHelpers.tests.cpp",
    "IntrospectiveTests/ColourImpl.tests.cpp",
    "IntrospectiveTests/Details.tests.cpp",
    "IntrospectiveTests/FloatingPoint.tests.cpp",
    "IntrospectiveTests/GeneratorsImpl.tests.cpp",
    "IntrospectiveTests/Integer.tests.cpp",
    "IntrospectiveTests/InternalBenchmark.tests.cpp",
    "IntrospectiveTests/Json.tests.cpp",
    "IntrospectiveTests/Parse.tests.cpp",
    "IntrospectiveTests/PartTracker.tests.cpp",
    "IntrospectiveTests/RandomNumberGeneration.tests.cpp",
    "IntrospectiveTests/Reporters.tests.cpp",
    "IntrospectiveTests/Tag.tests.cpp",
    "IntrospectiveTests/TestCaseInfoHasher.tests.cpp",
    "IntrospectiveTests/TestSpec.tests.cpp",
    "IntrospectiveTests/TestSpecParser.tests.cpp",
    "IntrospectiveTests/TextFlow.tests.cpp",
    "IntrospectiveTests/Sharding.tests.cpp",
    "IntrospectiveTests/Stream.tests.cpp",
    "IntrospectiveTests/String.tests.cpp",
    "IntrospectiveTests/StringManip.tests.cpp",
    "IntrospectiveTests/Xml.tests.cpp",
    "IntrospectiveTests/Traits.tests.cpp",
    "IntrospectiveTests/ToString.tests.cpp",
    "IntrospectiveTests/UniquePtr.tests.cpp",
    "helpers/parse_test_spec.cpp",
    "TimingTests/Sleep.tests.cpp",
    "UsageTests/Approx.tests.cpp",
    "UsageTests/BDD.tests.cpp",
    "UsageTests/Benchmark.tests.cpp",
    "UsageTests/Class.tests.cpp",
    "UsageTests/Compilation.tests.cpp",
    "UsageTests/Condition.tests.cpp",
    "UsageTests/Decomposition.tests.cpp",
    "UsageTests/EnumToString.tests.cpp",
    "UsageTests/Exception.tests.cpp",
    "UsageTests/Generators.tests.cpp",
    "UsageTests/Message.tests.cpp",
    "UsageTests/Misc.tests.cpp",
    "UsageTests/Skip.tests.cpp",
    "UsageTests/ToStringByte.tests.cpp",
    "UsageTests/ToStringChrono.tests.cpp",
    "UsageTests/ToStringGeneral.tests.cpp",
    "UsageTests/ToStringOptional.tests.cpp",
    "UsageTests/ToStringPair.tests.cpp",
    "UsageTests/ToStringTuple.tests.cpp",
    "UsageTests/ToStringVariant.tests.cpp",
    "UsageTests/ToStringVector.tests.cpp",
    "UsageTests/ToStringWhich.tests.cpp",
    "UsageTests/Tricky.tests.cpp",
    "UsageTests/VariadicMacros.tests.cpp",
    "UsageTests/MatchersRanges.tests.cpp",
    "UsageTests/Matchers.tests.cpp",
};
