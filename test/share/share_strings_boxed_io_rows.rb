# Builtin IO calls read the supplied String and return independent paths
# and lines even when an element lookup boxes the receiver.
require 'tmpdir'
path = File.join(Dir.tmpdir, "spinel_io_rows_#{Process.pid}")
file = File.open(path, 'w+')
text = +'line'
box = [file, nil]
p box[0].write(text)
text << '!'
file.rewind
line = box[0].gets
line << '?'
file.rewind
p [line, box[0].gets, text]
[box[0].path, box[0].to_path].each do |name|
  name << '!'
  p box[0].path == path
end
file.close
File.delete(path)
dir = Dir.open(Dir.tmpdir)
dirs = [dir, nil]
name = dirs[0].to_path
name << '!'
p dirs[0].to_path == Dir.tmpdir
dir.close
