const std = @import("std");

const CX = 16;
const CY = 32;
const CZ = 16;

var blocks: [CY][CZ][CX]u8 = undefined;

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

fn solid(x: i32, y: i32, z: i32) bool {
    if (x < 0 or y < 0 or z < 0) return false;
    if (x >= CX or y >= CY or z >= CZ) return false;
    return blocks[@intCast(y)][@intCast(z)][@intCast(x)] != 0;
}

pub fn main() void {
    for (0..CY) |y| {
        for (0..CZ) |z| {
            for (0..CX) |x| blocks[y][z][x] = 0;
        }
    }

    for (0..CZ) |z| {
        for (0..CX) |x| {
            const fx: f32 = @floatFromInt(x);
            const fz: f32 = @floatFromInt(z);
            const h = noise(fx * 0.12, fz * 0.12) * 0.7 + noise(fx * 0.35, fz * 0.35) * 0.3;
            const tinggi: usize = 6 + @as(usize, @intFromFloat(h * 16.0));
            for (0..tinggi) |y| {
                blocks[y][z][x] = if (y == tinggi - 1) 2 else 1;
            }
        }
    }

    const arah = [6][3]i32{
        .{ 1, 0, 0 }, .{ -1, 0, 0 },
        .{ 0, 1, 0 }, .{ 0, -1, 0 },
        .{ 0, 0, 1 }, .{ 0, 0, -1 },
    };

    var padat: u32 = 0;
    var total: u32 = 0;
    var terlihat: u32 = 0;

    for (0..CY) |y| {
        for (0..CZ) |z| {
            for (0..CX) |x| {
                const xi: i32 = @intCast(x);
                const yi: i32 = @intCast(y);
                const zi: i32 = @intCast(z);
                if (!solid(xi, yi, zi)) continue;
                padat += 1;
                for (arah) |d| {
                    total += 1;
                    if (!solid(xi + d[0], yi + d[1], zi + d[2])) terlihat += 1;
                }
            }
        }
    }

    const byte_vertex: f32 = @floatFromInt(terlihat * 4 * 12);
    const byte_index: f32 = @floatFromInt(terlihat * 6 * 4);

    std.debug.print("Blok padat      : {d}\n", .{padat});
    std.debug.print("Sisi semua      : {d}\n", .{total});
    std.debug.print("Sisi terlihat   : {d}\n", .{terlihat});
    std.debug.print("Segitiga ke GPU : {d}\n", .{terlihat * 2});
    std.debug.print("Memori mesh     : {d:.1} KB\n", .{(byte_vertex + byte_index) / 1024.0});
}
