#!/bin/sh

mkdir -p parser
zig build
cp -r zig-out/lib/*.so parser/
