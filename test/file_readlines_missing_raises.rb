# File.readlines of a file that can't be opened raises, as CRuby does: it
# answered [] and a missing config file looked like an empty one.
require "tmpdir"

missing = File.join(Dir.tmpdir, "spinel_no_such_dir_#{Process.pid}", "x.ini")
[-> { File.readlines(missing) }, -> { File.readlines(missing, chomp: true) }].each do |read|
  read.call
  p :no_error
rescue Errno::ENOENT => e
  p e.class
  p e.message.start_with?("No such file or directory @ rb_sysopen - ")
end

path = File.join(Dir.tmpdir, "spinel_readlines_#{Process.pid}")
File.write(path, "a\nb\n")
p File.readlines(path)
p File.readlines(path, chomp: true)
File.delete(path)
