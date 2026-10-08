# spinel: share
# spinel: gc-minor
# File.readable? only reads its path. An unrelated proc can mutate a String
# without making that path an alias of the proc's argument.
require "tmpdir"
path = File.join(Dir.tmpdir, "spinel_share_readable_#{Process.pid}.txt")
File.write(path, "readable")
original = path.dup
p File.readable?(path)
p FileTest.readable?(path)
p path == original
p File.readable?(path.freeze)
p FileTest.readable?(path)
path = +path
path << ".missing"
p File.readable?(path)
p FileTest.readable?(path)
File.delete(original)
mutator = ->(value) { value << "!" }
text = +"live"
mutator.call(text)
p text
