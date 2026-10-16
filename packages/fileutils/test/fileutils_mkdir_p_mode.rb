require "fileutils"
require "tmpdir"

# FileUtils.mkdir_p with mode: gives the mode to each directory it creates,
# the missing parents included, and leaves a directory that already exists
# as it was.
root = File.join(Dir.tmpdir, "spinel_fu_mkdir_p_mode_#{Process.pid}")
File.umask(0o022)
existing = File.join(root, "existing")
FileUtils.mkdir_p(existing)
FileUtils.mkdir_p(existing, mode: 0o700)
p File.stat(existing).mode.to_s(8)

leaf = File.join(root, "made", "leaf")
FileUtils.mkdir_p(leaf, mode: 0o700)
p File.stat(File.join(root, "made")).mode.to_s(8)
p File.stat(leaf).mode.to_s(8)

FileUtils.rm_rf(root)
