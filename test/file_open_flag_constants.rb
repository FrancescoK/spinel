# File::NOFOLLOW, NOCTTY, SYNC and DSYNC are the open(2) flags of the
# platform, and File.open passes them on. A failed open raises the Errno
# class of its errno: ELOOP for a symlink under NOFOLLOW, ENOTDIR for a
# path through a regular file.
require "tmpdir"
dir = File.join(Dir.tmpdir, "sp_open_flags_#{Process.pid}")
Dir.mkdir(dir)
target = File.join(dir, "target")
link = File.join(dir, "link")
File.write(target, "data")
File.symlink(target, link)

p [File::NOFOLLOW, File::NOCTTY, File::SYNC, File::DSYNC].all?(Integer)
p File.open(target, File::RDONLY | File::NOFOLLOW) { |f| f.read }
p File.open(target, File::RDONLY | File::NOCTTY) { |f| f.read }
begin
  File.open(link, File::RDONLY | File::NOFOLLOW) { :opened }
rescue Errno::ELOOP
  puts "ELOOP"
end
begin
  File.open(File.join(target, "x"), File::RDONLY) { :opened }
rescue Errno::ENOTDIR
  puts "ENOTDIR"
end

written = File.join(dir, "written")
File.open(written, File::WRONLY | File::CREAT | File::SYNC) { |f| f.write("sync") }
File.open(written, File::WRONLY | File::APPEND | File::DSYNC) { |f| f.write(" dsync") }
p File.read(written)

File.delete(written)
File.delete(link)
File.delete(target)
Dir.rmdir(dir)
