require "tmpdir"
path = File.join(Dir.tmpdir, "share_verify_buffer_#{Process.pid}.txt")
File.write(path, "XYZ")
def rd(f, s) = f.read(2, s)
c = +"c"
File.open(path) { |f| rd(f, c) }
p c
class H
  attr_accessor :buf
  def initialize; @buf = +"h"; end
end
h = H.new
File.open(path) { |f| f.read(2, h.buf) }
p h.buf
arr = [+"a"]
File.open(path) { |f| f.read(2, arr[0]) }
p arr

File.delete(path)
