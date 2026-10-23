# spinel: gc-stress
require "tmpdir"
path = File.join(Dir.tmpdir, "spinel-file-codepoints-#{Process.pid}.txt")
File.write(path, "aé\n")
f = [File.open(path), 0][0]
begin
  p f.each_codepoint.to_a
  f.rewind
  e = f.each_codepoint
  p e.next
  p e.next
  e.rewind
  p e.next
  p f.each_codepoint.to_a
ensure
  f.close
  File.delete(path)
end
