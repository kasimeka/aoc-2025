const std = @import("std");
const fmt = std.fmt;
const math = std.math;
const mem = std.mem;
const sort = std.sort;
const Allocator = mem.Allocator;
const ArrayList = std.ArrayList;
const Io = std.Io;

const ALLOCATOR_BUF_SIZE = 2 * 1024 * 1024;
const IO_BUF_SIZE = 32 * 1024;

const Input = Input; // TODO

fn solve(gpa: Allocator, input: *Io.Reader, output: *Io.Writer) !void {
    const res = try parseInput(gpa, input);
    defer gpa.free(res);

    _ = output;
}
fn part1(input: Input) u64 {
    _ = input;
}
fn part2(input: Input) void {
    _ = input;
}

const Lexeme = enum { range, id };
fn parseInput(gpa: Allocator, input: *Io.Reader) !Input {
    _ = gpa;
    _ = input;
}

pub fn main() !void {
    var allocator_buf: [ALLOCATOR_BUF_SIZE]u8 = undefined;
    var fixed_buffer_allocator = std.heap.FixedBufferAllocator.init(&allocator_buf);

    var threaded = Io.Threaded.init_single_threaded;
    const io = threaded.io();

    var in_buf: [IO_BUF_SIZE]u8 = undefined;
    var input = (try std.fs.cwd().openFile("input", .{})).reader(io, &in_buf);

    var out_buf: [IO_BUF_SIZE]u8 = undefined;
    var stdout = std.fs.File.stdout().writer(&out_buf);

    try solve(fixed_buffer_allocator.allocator(), &input.interface, &stdout.interface);
}
