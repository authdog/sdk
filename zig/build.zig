const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // Create static library
    const lib = b.addStaticLibrary(.{
        .name = "authdog",
        .root_source_file = .{ .path = "src/lib.zig" },
        .target = target,
        .optimize = optimize,
    });

    // No external dependencies - using standard library only

    b.installArtifact(lib);

    // Create example executable
    const exe = b.addExecutable(.{
        .name = "authdog_example",
        .root_source_file = .{ .path = "examples/main.zig" },
        .target = target,
        .optimize = optimize,
    });
    
    // Use root_module.addImport for Zig 0.12.0+
    exe.root_module.addImport("authdog", &lib.root_module);

    b.installArtifact(exe);

    // Create tests
    const tests = b.addTest(.{
        .root_source_file = .{ .path = "src/test.zig" },
        .target = target,
        .optimize = optimize,
    });
    
    // Use root_module.addImport for Zig 0.12.0+
    tests.root_module.addImport("authdog", &lib.root_module);

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
