const std = @import("std");

const grammars_json = @embedFile("grammars.json");

fn load_grammars_json(b: *std.Build) []TreeSitter {
    const grammars = std.json.parseFromSlice(
        []TreeSitter,
        b.allocator,
        grammars_json,
        .{ .ignore_unknown_fields = true },
    ) catch @panic("invalid grammars.json");
    return grammars.value;
}

const TreeSitter = struct {
    /// Language name (elixir, python, etc.)
    name: []const u8,
    /// Source files to compile. Default is only `src/parser.c`.
    files: []const []const u8 = &.{"src/parser.c"},
    /// C source include paths. Default to `src`.
    include_paths: []const []const u8 = &.{"src"},
};

fn tree_sitter_library(
    b: *std.Build,
    target: std.Build.ResolvedTarget,
    optimize: std.builtin.OptimizeMode,
    ts: TreeSitter,
) *std.Build.Step.InstallArtifact {
    const dep = b.dependency(
        b.fmt("tree-sitter-{s}", .{ts.name}),
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

    for (ts.include_paths) |include_path| {
        module.addIncludePath(dep.path(include_path));
    }

    const lib = b.addLibrary(.{
        .name = ts.name,
        .linkage = .dynamic,
        .root_module = module,
    });

    return b.addInstallArtifact(lib, .{
        .dest_sub_path = b.fmt("{s}.so", .{ts.name}),
    });
}

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    for (load_grammars_json(b)) |ts| {
        b.getInstallStep().dependOn(&tree_sitter_library(b, target, optimize, ts).step);
    }
}
