const std = @import("std");

const grammars_json = @embedFile("grammars.json");

fn load_grammars_json(b: *std.Build) ![]TreeSitter {
    const grammars = try std.json.parseFromSlice(
        []TreeSitter,
        b.allocator,
        grammars_json,
        .{ .ignore_unknown_fields = true },
    );
    return grammars.value;
}

const TreeSitter = struct {
    /// The language name (for example, `elixir` or `python`).
    name: []const u8,
    /// The grammar directory within the package (for example, `typescript` in the `tree-sitter-typescript` package).
    sub_path: []const u8 = "",
};

// TODO: Read tree-sitter.json to compile grammars automatically.
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
    const root = dep.path(ts.sub_path);

    const module = b.createModule(.{
        .target = target,
        .optimize = optimize,
        .link_libc = true,
    });
    module.addCSourceFile(.{
        .file = root.path(b, "src/parser.c"),
        .flags = &.{"-std=c11"},
    });
    if (hasScanner(b, root)) {
        module.addCSourceFile(.{
            .file = root.path(b, "src/scanner.c"),
            .flags = &.{"-std=c11"},
        });
    }
    module.addIncludePath(root.path(b, "src"));

    const lib = b.addLibrary(.{
        .name = ts.name,
        .linkage = .dynamic,
        .root_module = module,
    });

    return b.addInstallArtifact(lib, .{
        .dest_sub_path = b.fmt("{s}.so", .{ts.name}),
    });
}

fn hasScanner(b: *std.Build, root: std.Build.LazyPath) bool {
    const path = root.getPath4(b, null) catch return false;
    path.access(b.graph.io, "src/scanner.c", .{}) catch return false;
    return true;
}

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    for (try load_grammars_json(b)) |ts| {
        b.getInstallStep().dependOn(&tree_sitter_library(b, target, optimize, ts).step);
    }
}
