const std = @import("std");

const TS_PKGS = .{
    "elixir",
    "iex",
    "javascript",
    "typescript",
};

const TreeSitter_Grammar = struct {
    name: []const u8,
    path: []const u8,
};

/// `tree-sitter.json` schema. Pick only interest in build.
const TreeSitter = struct {
    grammars: []const TreeSitter_Grammar,
};

fn parseTreeSitterJson(b: *std.Build, lazy_path: std.Build.LazyPath) !TreeSitter {
    const path = try lazy_path.getPath4(b, null);
    const tree_sitter_json = try path.root_dir.handle.readFileAlloc(
        b.graph.io,
        path.sub_path,
        b.allocator,
        .unlimited,
    );
    const ts = try std.json.parseFromSlice(
        TreeSitter,
        b.allocator,
        tree_sitter_json,
        .{ .ignore_unknown_fields = true },
    );
    return ts.value;
}

fn installTreeSitterParser(
    b: *std.Build,
    target: std.Build.ResolvedTarget,
    optimize: std.builtin.OptimizeMode,
    name: []const u8,
) !void {
    const dep = b.dependency(
        b.fmt("tree-sitter-{s}", .{name}),
        .{
            .target = target,
            .optmize = optimize,
        },
    );

    const tree_sitter_json = dep.path("tree-sitter.json");
    // Default to current path of `dep` if the `tree-sitter.json` doesn't exists.
    const ts_json = if (hasFile(b, tree_sitter_json)) try parseTreeSitterJson(b, tree_sitter_json) else TreeSitter{
        .grammars = &[_]TreeSitter_Grammar{
            .{ .name = name, .path = "." },
        },
    };

    for (ts_json.grammars) |grammar| {
        const root = dep.path(grammar.path);

        const module = b.createModule(.{
            .target = target,
            .optimize = optimize,
            .link_libc = true,
        });
        module.addCSourceFile(.{
            .file = root.path(b, "src/parser.c"),
            .flags = &.{"-std=c11"},
        });
        const scanner_c = root.path(b, "src/scanner.c");
        if (hasFile(b, scanner_c)) {
            module.addCSourceFile(.{
                .file = scanner_c,
                .flags = &.{"-std=c11"},
            });
        }
        module.addIncludePath(root.path(b, "src"));

        const lib = b.addLibrary(.{
            .name = grammar.name,
            .linkage = .dynamic,
            .root_module = module,
        });

        b.getInstallStep().dependOn(
            &b.addInstallArtifact(lib, .{
                .dest_sub_path = b.fmt("{s}.so", .{grammar.name}),
            }).step,
        );
    }
}

fn hasFile(b: *std.Build, root: std.Build.LazyPath) bool {
    const path = root.getPath4(b, null) catch return false;
    path.root_dir.handle.access(b.graph.io, path.sub_path, .{}) catch return false;
    return true;
}

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    inline for (TS_PKGS) |ts| {
        try installTreeSitterParser(b, target, optimize, ts);
    }
}
