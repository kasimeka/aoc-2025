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

const Input = Pair([]Range, []u64);
const Range = Pair(u64, u64);
fn rangeLessThan(_: void, left: Range, right: Range) bool {
    return left.@"0" < right.@"0";
}
fn Pair(left: type, right: type) type {
    return struct { left, right };
}

fn solve(gpa: Allocator, input: *Io.Reader, output: *Io.Writer) !void {
    const ranges, const ids = try parseInput(gpa, input);
    defer {
        gpa.free(ranges);
        gpa.free(ids);
    }

    std.debug.print("{any}, {any}\n", .{ ranges[0], ids[0] });
    try output.print("part1: {d}\n", .{part1(.{ ranges, ids })});
    try output.print("part2: {d}\n", .{part2(.{ ranges, ids })});
    try output.flush();
}
fn part1(input: Input) u64 {
    const ranges, const ids = input;
    var count: u64 = 0;
    ids: for (ids) |id|
        for (ranges) |range| {
            if (range.@"0" <= id and id <= range.@"1") {
                count += 1;
                continue :ids;
            }
        };
    return count;
}
fn part2(input: Input) u64 {
    const ranges, _ = input;
    std.sort.block(Range, ranges, {}, rangeLessThan);

    var count: u64 = 0;

    var last: ?Range = null;
    for (ranges) |range| {
        const start, const end = range;
        if (last) |*l|
            if (start <= l.@"1") {
                l.*.@"1" = @max(l.@"1", end);
            } else {
                count += l.@"1" - l.@"0" + 1;
                last = range;
            }
        else
            last = range;
    }
    count += last.?.@"1" - last.?.@"0" + 1;

    return count;
}

const Lexeme = enum { range, id };
fn parseInput(gpa: Allocator, input: *Io.Reader) !Input {
    var ranges = try ArrayList(Range).initCapacity(gpa, 128);
    defer ranges.deinit(gpa);
    var ids = try ArrayList(u64).initCapacity(gpa, 512);
    defer ids.deinit(gpa);

    parse: switch (Lexeme.range) {
        .range => {
            const line = try input.takeDelimiterExclusive('\n');
            input.toss(1);

            var lineParts = mem.splitScalar(u8, line, '-');
            const first = lineParts.next().?;
            const second = lineParts.next() orelse continue :parse .id;

            const start = try fmt.parseInt(u64, first, 10);
            const end = try fmt.parseInt(u64, second, 10);

            try ranges.append(gpa, .{ start, end });
            continue :parse .range;
        },
        .id => {
            const line = input.takeDelimiterExclusive('\n') catch |e| switch (e) {
                error.EndOfStream => return .{ try ranges.toOwnedSlice(gpa), try ids.toOwnedSlice(gpa) },
                else => return e,
            };
            const id = try fmt.parseInt(u64, line, 10);

            try ids.append(gpa, id);
            continue :parse .range;
        },
    }
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
