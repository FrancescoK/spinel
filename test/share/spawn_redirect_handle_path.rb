# spinel: share
# A spawn's filename redirection given a String that is the shared handle
# (a name aliases it and changes it in place) opens that file: the
# generated redirect test took a boxed String by its tag alone. A chdir:
# directory given such a String is the child's directory: the same tag
# test read it as no directory and the child ran in the parent's.
require "tmpdir"
Dir.mktmpdir do |d|
  path = +"#{d}/out.txt"
  q = path
  q << ""
  opts = { out: [path, 1][0] }
  pid = Process.spawn("/bin/echo", "hi", **opts)
  Process.wait(pid)
  p File.read(path)
end

Dir.mktmpdir do |d|
  dir = +"#{d}/sub"
  q = dir
  q << ""
  Dir.mkdir(dir)
  r, w = IO.pipe
  opts = { chdir: [dir, 1][0], out: w }
  pid = Process.spawn("/bin/pwd", **opts)
  w.close
  Process.wait(pid)
  p File.realpath(r.read.chomp) == File.realpath(dir)
  r.close
end
