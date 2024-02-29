const std = @import("std");
const builtin = @import("builtin");
const elf = std.elf;
const assert = std.debug.assert;
extern fn main() void;

const R_AMD64_RELATIVE = 8;
const R_386_RELATIVE = 8;
const R_ARM_RELATIVE = 23;
const R_AARCH64_RELATIVE = 1027;
const R_RISCV_RELATIVE = 3;
const R_SPARC_RELATIVE = 22;

const R_RELATIVE = switch (builtin.cpu.arch) {
    .x86 => R_386_RELATIVE,
    .x86_64 => R_AMD64_RELATIVE,
    .arm => R_ARM_RELATIVE,
    .aarch64 => R_AARCH64_RELATIVE,
    .riscv64 => R_RISCV_RELATIVE,
    else => @compileError("Missing R_RELATIVE definition for this target"),
};

export fn __bootstrapper(base_addr: usize, dynv: [*]elf.Dyn) void {
    @setRuntimeSafety(false);
    var rel_addr: usize = 0;
    var rela_addr: usize = 0;
    var rel_size: usize = 0;
    var rela_size: usize = 0;
    {
        var i: usize = 0;
        while (dynv[i].d_tag != elf.DT_NULL) : (i += 1) {
            switch (dynv[i].d_tag) {
                elf.DT_REL => rel_addr = base_addr + dynv[i].d_val,
                elf.DT_RELA => rela_addr = base_addr + dynv[i].d_val,
                elf.DT_RELSZ => rel_size = dynv[i].d_val,
                elf.DT_RELASZ => rela_size = dynv[i].d_val,
                else => {},
            }
        }
    }

    // Apply the relocations.
    if (rel_addr != 0) {
        const rel = std.mem.bytesAsSlice(elf.Rel, @as([*]u8, @ptrFromInt(rel_addr))[0..rel_size]);
        for (rel) |r| {
            if (r.r_type() != R_RELATIVE) continue;
            @as(*usize, @ptrFromInt(base_addr + r.r_offset)).* += base_addr;
        }
    }
    if (rela_addr != 0) {
        const rela = std.mem.bytesAsSlice(elf.Rela, @as([*]u8, @ptrFromInt(rela_addr))[0..rela_size]);
        for (rela) |r| {
            if (r.r_type() != R_RELATIVE) continue;
            @as(*usize, @ptrFromInt(base_addr + r.r_offset)).* += base_addr + @as(usize, @bitCast(r.r_addend));
        }
    }

    // Call main
    main();
}
