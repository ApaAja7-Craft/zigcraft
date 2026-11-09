const std = @import("std");

fn hash(x: i32, z: i32) u32 {
    var h: u32 = @bitCast(x *% 374761393 +% z *% 668265263);
    h = (h ^ (h >> 13)) *% 1274126177;
    return h ^ (h >> 16);
}

fn nilai(x: i32, z: i32) f32 {
    const bit: u32 = hash(x, z) & 0xFFFF;
    return @as(f32, @floatFromInt(bit)) / 65535.0;
}

fn halus(t: f32) f32 {
    return t * t * (3.0 - 2.0 * t);
}

fn noise(x: f32, z: f32) f32 {
    const fx = @floor(x);
    const fz = @floor(z);
    const x0: i32 = @intFromFloat(fx);
    const z0: i32 = @intFromFloat(fz);
    const tx = halus(x - fx);
    const tz = halus(z - fz);

    const a = nilai(x0, z0);
    const b = nilai(x0 + 1, z0);
    const c = nilai(x0, z0 + 1);
    const d = nilai(x0 + 1, z0 + 1);

    const atas = a + (b - a) * tx;
    const bawah = c + (d - c) * tx;
    return atas + (bawah - atas) * tz;
}

pub fn main() void {
    for (0..16) |z| {
        for (0..40) |x| {
            const fx: f32 = @floatFromInt(x);
            const fz: f32 = @floatFromInt(z);
            const h = noise(fx * 0.12, fz * 0.12) * 0.7 + noise(fx * 0.35, fz * 0.35) * 0.3;
            const digit: u8 = @intFromFloat(h * 9.99);
            std.debug.print("{c}", .{'0' + digit});
        }
        std.debug.print("\n", .{});
    }
}
