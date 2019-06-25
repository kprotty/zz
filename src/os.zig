const std = @import("std");
const builtin = @import("builtin");

pub const mem = struct {
    usingnamespace MemoryBackend;

    pub inline fn ptrCast(comptime Ptr: type, pointer: var) Ptr {
        return @intToPtr(Ptr, @ptrToInt(pointer));
    }

    const MemoryBackend = switch (builtin.os) {
        .windows => struct {
            const windows = std.os.windows;

            pub fn alloc(bytes: usize) ![]u8 {
                const address = ptrCast(?[*]u8, windows.VirtualAlloc(
                    null,
                    bytes,
                    windows.MEM_RESERVE,
                    windows.PAGE_READWRITE,
                )) orelse return error.OutOfMemory;
                return address[0..bytes];
            }

            pub fn free(memory: []const u8) void {
                const address = ptrCast(windows.LPVOID, memory.ptr);
                _ = windows.VirtualFree(address, 0, windows.MEM_RELEASE);
            }
        },
        .linux, .macosx => struct {
            pub fn alloc(bytes: usize) ![]u8 {
                const memory = std.os.mmap(
                    null,
                    bytes,
                    std.os.PROT_READ | std.os.PROT_WRITE,
                    std.os.MAP_PRIVATE | std.os.MAP_ANONYMOUS,
                    -1,
                    0
                ) catch return error.OutOfMemory;
                return memory;
            }

            pub fn free(memory: []const u8) void {
               std.os.munmap(memory); 
            }
        },
        else => {
            pub fn alloc(bytes: usize) ![]u8 {
                const address = std.c.malloc(bytes) orelse return error.OutOfMemory;
                return ptrCast([*]u8, address)[0..bytes];
            }

            pub fn free(memory: []const u8) void {
                std.c.free(ptrCast(*c_void, memory.ptr));
            }
        },
    };
};

