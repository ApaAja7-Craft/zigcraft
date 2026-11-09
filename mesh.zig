const std = @import("std");

const N = 8;
const MAX_SISI = N * N * N * 6;

const arah = [6][3]i32{
    .{ 1, 0, 0 }, .{ -1, 0, 0 },
    .{ 0, 1, 0 }, .{ 0, -1, 0 },
    .{ 0, 0, 1 }, .{ 0, 0, -1 },
};

const sudut = [6][4][3]f32{
    .{ .{ 1, 0, 0 }, .{ 1, 1, 0 }, .{ 1, 1, 1 }, .{ 1, 0, 1 } },
    .{ .{ 0, 0, 1 }, .{ 0, 1, 1 }, .{ 0, 1, 0 }, .{ 0, 0, 0 } },
    .{ .{ 0, 1, 0 }, .{ 0, 1, 1 }, .{ 1, 1, 1 }, .{ 1, 1, 0 } },
    .{ .{ 0, 0, 1 }, .{ 0, 0, 0 }, .{ 1, 0, 0 }, .{ 1, 0, 1 } },
    .{ .{ 0, 0, 1 }, .{ 1, 0, 1 }, .{ 1, 1, 1 }, .{ 0, 1, 1 } },
    .{ .{ 1, 0, 0 }, .{ 0, 0, 0 }, .{ 0, 1, 0 }, .{ 1, 1, 0 } },
};

var blocks: [N][N][N]bool = undefined;
var verts: [MAX_SISI * 4][3]f32 = undefined;
var indeks: [MAX_SISI * 6]u32 = undefined;

fn solid(x: i32, y: i32, z: i32) bool {
    if (x < 0 or y < 0 or z < 0) return false;
    if (x >= N or y >= N or z >= N) return false;
    return blocks[@intCast(y)][@intCast(z)][@intCast(x)];
}

pub fn main() void {
    for (0..N) |y| {
        for (0..N) |z| {
            for (0..N) |x| {
                const tinggi: usize = 3 + (x + z) % 3;
                blocks[y][z][x] = y < tinggi;
            }
        }
    }

    var nv: usize = 0;
    var ni: usize = 0;

    for (0..N) |y| {
        for (0..N) |z| {
            for (0..N) |x| {
                const xi: i32 = @intCast(x);
                const yi: i32 = @intCast(y);
                const zi: i32 = @intCast(z);
                if (!solid(xi, yi, zi)) continue;

                for (arah, 0..) |d, di| {
                    if (solid(xi + d[0], yi + d[1], zi + d[2])) continue;

                    const base: u32 = @intCast(nv);
                    const fx: f32 = @floatFromInt(x);
                    const fy: f32 = @floatFromInt(y);
                    const fz: f32 = @floatFromInt(z);
                    for (sudut[di]) |k| {
                        verts[nv] = .{ fx + k[0], fy + k[1], fz + k[2] };
                        nv += 1;
                    }
                    const pola = [6]u32{ 0, 1, 2, 0, 2, 3 };
                    for (pola) |p| {
                        indeks[ni] = base + p;
                        ni += 1;
                    }
                }
            }
        }
    }

    std.debug.print("Vertex: {d}\nIndex: {d}\nSegitiga: {d}\n", .{ nv, ni, ni / 3 });
    std.debug.print("Titik pertama: {d}, {d}, {d}\n", .{ verts[0][0], verts[0][1], verts[0][2] });
}
