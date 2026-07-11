const std = @import("std");

const TreeSitter = struct {
    /// Language name (elixir, python, etc.)
    name: []const u8,
    /// Source files to compile. Default is only `src/parser.c`.
    files: []const []const u8 = &.{"src/parser.c"},
};

fn tree_sitter_library(
    b: *std.Build,
    target: std.Build.ResolvedTarget,
    optimize: std.builtin.OptimizeMode,
    comptime ts: TreeSitter,
) *std.Build.Step.InstallArtifact {
    const dep = b.dependency(
        std.fmt.comptimePrint("tree-sitter-{s}", .{ts.name}),
        .{
            .target = target,
            .optmize = optimize,
        },
    );

    const module = b.createModule(.{
        .target = target,
        .optimize = optimize,
        .link_libc = true,
    });
    module.addCSourceFiles(.{
        .root = dep.path(""),
        .files = ts.files,
        .flags = &.{"-std=c11"},
    });

    const lib = b.addLibrary(.{
        .name = ts.name,
        .linkage = .dynamic,
        .root_module = module,
    });

    return b.addInstallArtifact(lib, .{
        .dest_sub_path = std.fmt.comptimePrint("{s}.so", .{ts.name}),
    });
}

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    b.getInstallStep().dependOn(
        &tree_sitter_library(b, target, optimize, .{
            .name = "elixir",
            .files = &.{
                "src/parser.c",
                "src/scanner.c",
            },
        }).step,
    );
}
