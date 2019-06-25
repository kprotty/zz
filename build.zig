const Builder = @import("std").build.Builder;

pub fn build(b: *Builder) void {
    const zz = b.addExecutable("zz", "src/main.zig");
    zz.setBuildMode(b.standardReleaseOptions());
    zz.setOutputDir("zig-cache");
    zz.setMainPkgPath("src/");

    b.default_step.dependOn(&zz.step);
    b.installArtifact(zz);
}