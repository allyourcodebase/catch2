const std = @import("std");

const Io = std.Io;
const File = Io.File;

const State = union(enum) {
    outside: void,
    inside_file_list: []u8,
};

pub fn main(init: std.process.Init) !void {
    const alloc = init.arena.allocator();

    var state: State = .outside;
    var stdin_file_reader: File.Reader = File.stdin().reader(init.io, try alloc.alloc(u8, 2048));
    var stdout_file_writer: File.Writer = File.stdout().writer(init.io, try alloc.alloc(u8, 2048));
    var input: *Io.Reader = &stdin_file_reader.interface;
    var output: *Io.Writer = &stdout_file_writer.interface;
    defer output.flush() catch unreachable;
    var current_list: std.ArrayList([]u8) = .empty;

    while (try input.takeDelimiter('\n')) |line| {
        //std.log.debug("[{t}] '{s}'", .{ state, line });
        switch (state) {
            .outside => {
                var halves = std.mem.splitScalar(u8, line, '=');
                const name = std.mem.trim(u8, halves.first(), " ");
                if (halves.next()) |_value| {
                    const value = std.mem.trim(u8, _value, " ");
                    //std.log.info("{s} <- {s}", .{ name, value });
                    if (std.mem.eql(u8, value, "files(")) {
                        std.log.debug("Reading file list {s}", .{name});
                        state = .{ .inside_file_list = try alloc.dupe(u8, name) };
                    }
                }
            },
            .inside_file_list => |list_name| {
                const filename = std.mem.trim(u8, line, " ',");
                if (std.mem.eql(u8, filename, ")")) {
                    state = .outside;
                    try output.print("pub const {s} = .{c}\n", .{ list_name, '{' });
                    for (current_list.items) |file| {
                        try output.print("\t\"{s}\",\n", .{file});
                    }
                    try output.writeAll("};\n\n");
                    current_list.clearRetainingCapacity();
                } else {
                    try current_list.append(alloc, try alloc.dupe(u8, filename));
                }
            },
        }
    }
}
