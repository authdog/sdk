const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const lib = b.addStaticLibrary(.{
        .name = "authdog",
        .root_source_file = .{ .path = "src/lib.zig" },
        .target = target,
        .optimize = optimize,
    });

    // Add HTTP client dependency
    const ziggy_http_dep = b.dependency("ziggy-http", .{
        .target = target,
        .optimize = optimize,
    });
    lib.root_module.addImport("ziggy-http", ziggy_http_dep.module("ziggy-http"));

    // Add JSON parsing dependency
    const json_dep = b.dependency("json", .{
        .target = target,
        .optimize = optimize,
    });
    lib.root_module.addImport("json", json_dep.module("json"));

    b.installArtifact(lib);

    // Create example executable
    const exe = b.addExecutable(.{
        .name = "authdog_example",
        .root_source_file = .{ .path = "examples/main.zig" },
        .target = target,
        .optimize = optimize,
    });
    exe.root_module.addImport("authdog", lib.root_module);
    exe.root_module.addImport("ziggy-http", ziggy_http_dep.module("ziggy-http"));
    exe.root_module.addImport("json", json_dep.module("json"));

    b.installArtifact(exe);

    // Create tests
    const tests = b.addTest(.{
        .root_source_file = .{ .path = "src/lib.zig" },
        .target = target,
        .optimize = optimize,
    });
    tests.root_module.addImport("ziggy-http", ziggy_http_dep.module("ziggy-http"));
    tests.root_module.addImport("json", json_dep.module("json"));

    const test_run = b.addRunArtifact(tests);
    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&test_run.step);

    // Create docs
    const docs = b.addInstallDirectory(.{
        .source_dir = lib.getEmittedDocs(),
        .install_dir = .prefix,
        .install_subdir = "docs",
    });

    const docs_step = b.step("docs", "Generate documentation");
    docs_step.dependOn(&docs.step);
}
