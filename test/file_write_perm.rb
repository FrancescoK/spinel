# File.write and File.binwrite with perm: create the file with those
# permission bits, with or without mode:. A file that already exists keeps
# its own bits, as in CRuby, and a nil perm is the default, 0666 less the
# umask: fix the umask, so the expected modes do not depend on who runs it.
# cwd-relative: Windows MinGW has no /tmp (see feedback_windows_tmp_path)
File.umask(022)
path = "spinel_write_perm_#{Process.pid}.tmp"
bits = ->(file) { format("%o", File.stat(file).mode & 0777) }

p File.write(path, "secret\n", perm: 0600)
p bits.(path), File.read(path)
p File.write(path, "more\n", mode: "a", perm: 0644)
p bits.(path), File.read(path)
File.delete(path)

p File.binwrite(path, "\x00\x01".b, perm: 0640)
p bits.(path), File.binread(path)
File.delete(path)

p File.write(path, "x", mode: "w", perm: 0604)
p bits.(path)
File.delete(path)

options = { perm: 0611, name: "boxed" }
p File.write(path, "y", perm: options[:perm])
p bits.(path)
File.delete(path)

p File.write(path, "z", perm: nil)
p bits.(path)
File.delete(path)
