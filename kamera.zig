const std = @import("std");

const Vec3 = [3]f32;
const Mat4 = [16]f32;

fn kurang(a: Vec3, b: Vec3) Vec3 {
    return .{ a[0] - b[0], a[1] - b[1], a[2] - b[2] };
}

fn titik(a: Vec3, b: Vec3) f32 {
    return a[0] * b[0] + a[1] * b[1] + a[2] * b[2];
}

fn silang(a: Vec3, b: Vec3) Vec3 {
    return .{
        a[1] * b[2] - a[2] * b[1],
        a[2] * b[0] - a[0] * b[2],
        a[0] * b[1] - a[1] * b[0],
    };
}

fn normal(a: Vec3) Vec3 {
    const p = @sqrt(titik(a, a));
    return .{ a[0] / p, a[1] / p, a[2] / p };
}

fn perspektif(fovy: f32, aspek: f32, dekat: f32, jauh: f32) Mat4 {
    const f = 1.0 / @tan(fovy / 2.0);
    var m: Mat4 = std.mem.zeroes(Mat4);
    m[0] = f / aspek;
    m[5] = -f;
    m[10] = jauh / (dekat - jauh);
    m[11] = -1.0;
    m[14] = (dekat * jauh) / (dekat - jauh);
    return m;
}

fn lihatKe(mata: Vec3, tujuan: Vec3, atas: Vec3) Mat4 {
    const f = normal(kurang(tujuan, mata));
    const s = normal(silang(f, atas));
    const u = silang(s, f);
    var m: Mat4 = std.mem.zeroes(Mat4);
    m[0] = s[0];
    m[1] = u[0];
    m[2] = -f[0];
    m[4] = s[1];
    m[5] = u[1];
    m[6] = -f[1];
    m[8] = s[2];
    m[9] = u[2];
    m[10] = -f[2];
    m[12] = -titik(s, mata);
    m[13] = -titik(u, mata);
    m[14] = titik(f, mata);
    m[15] = 1.0;
    return m;
}

fn kali(a: Mat4, b: Mat4) Mat4 {
    var m: Mat4 = undefined;
    for (0..4) |c| {
        for (0..4) |r| {
            var s: f32 = 0;
            for (0..4) |k| s += a[k * 4 + r] * b[c * 4 + k];
            m[c * 4 + r] = s;
        }
    }
    return m;
}

pub fn main() void {
    const lebar: f32 = 800;
    const tinggi: f32 = 600;

    const proj = perspektif(std.math.pi / 3.0, lebar / tinggi, 0.1, 100.0);
    const view = lihatKe(.{ 4, 10, 16 }, .{ 4, 3, 4 }, .{ 0, 1, 0 });
    const mvp = kali(proj, view);

    for (0..8) |i| {
        const x: f32 = if ((i & 1) != 0) 8 else 0;
        const y: f32 = if ((i & 2) != 0) 8 else 0;
        const z: f32 = if ((i & 4) != 0) 8 else 0;

        const v = [4]f32{ x, y, z, 1 };
        var o: [4]f32 = undefined;
        for (0..4) |r| {
            var s: f32 = 0;
            for (0..4) |c| s += mvp[c * 4 + r] * v[c];
            o[r] = s;
        }

        const px = (o[0] / o[3] * 0.5 + 0.5) * lebar;
        const py = (o[1] / o[3] * 0.5 + 0.5) * tinggi;
        std.debug.print("({d:.0}, {d:.0}, {d:.0}) -> layar ({d:.1}, {d:.1})\n", .{ x, y, z, px, py });
    }
}
