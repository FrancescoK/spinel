# IO#read with the subject as its buffer writes the subject.
require "tmpdir"
path = File.join(Dir.tmpdir, "rv2scan_#{$$}.txt")
File.write(path, "xyzw")
s = +"ab ab ab"
kept = []
begin
  File.open(path) do |f|
    s.scan(/ab/) { |m| m << "!"; kept << m; f.read(2, s) }
  end
rescue RuntimeError => e
  p e.message
end
File.delete(path)
p kept, s
