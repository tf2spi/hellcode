const std = @import("std");
export fn main() void {
    _ = std.os.linux.write(1, "Hello world!\n", 15);
    _ = std.os.linux.exit(0);
}
