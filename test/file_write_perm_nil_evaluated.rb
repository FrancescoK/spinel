# A perm: whose value is nil is still evaluated before the write, in the
# order CRuby evaluates the arguments, and the file gets the default bits:
# 0666 less the umask, fixed here so the expected mode does not depend on who
# runs it.
# cwd-relative: Windows MinGW has no /tmp (see feedback_windows_tmp_path)
File.umask(022)
path = "spinel_write_perm_nil_#{Process.pid}.tmp"

def default_bits
  puts "perm evaluated"
  nil
end

p File.write(path, "w", perm: default_bits)
p format("%o", File.stat(path).mode & 0777)
p File.binwrite(path, "bin", mode: "w", perm: default_bits)
p File.read(path)
File.delete(path)
