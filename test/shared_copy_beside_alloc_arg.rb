# spinel: gc-stress
# A read of a String slot that is appended to elsewhere hands the call a
# copy of its bytes. File.rename(@path, "#{to}") took that copy, then made
# the interpolation, which allocated and freed the copy before the call
# took it: under SPINEL_GC_STRESS=2 the rename got freed bytes.
require "tmpdir"
class Pa
  def initialize(path) = (@path = path)
  def to_s = @path.dup
  def add(s) = (@path << s; self)
  def rename(to) = File.rename(@path, "#{to}")
  def join(s) = File.join(@path, "#{s}")
end
d = Dir.tmpdir
a = Pa.new(+"#{d}/spinel_pa_#{Process.pid}")
a.add("")
File.write(a.to_s, "x")
b = Pa.new(+"#{d}/spinel_pb_#{Process.pid}")
p a.rename(b)
p File.exist?(b.to_s), a.join("q").end_with?("/q")
File.delete(b.to_s)
