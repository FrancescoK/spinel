require "fileutils"

# FileUtils.copy_file: the contents, the source's mode on a new file, and the
# times with preserve
dir = "/tmp/spinel_fu_copy_file_#{Process.pid}"
FileUtils.mkdir_p(dir)
src = "#{dir}/src.txt"
File.write(src, "hello")
File.chmod(0640, src)
File.utime(Time.at(1_577_934_240), Time.at(1_577_934_240), src)
p FileUtils.copy_file(src, "#{dir}/a")
p File.read("#{dir}/a"), File.stat("#{dir}/a").mode.to_s(8)
FileUtils.copy_file(src, "#{dir}/b", true)
p File.mtime("#{dir}/b") == File.mtime(src)
File.write("#{dir}/c", "a much longer old text")
FileUtils.copy_file(src, "#{dir}/c")
p File.read("#{dir}/c")
begin
  FileUtils.copy_file("#{dir}/missing", "#{dir}/d")
rescue SystemCallError => e
  p e.class
end
FileUtils.rm_rf(dir)
