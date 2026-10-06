# `other.instance_eval { @n += x }` updates other's @n, at the type other's
# class holds it -- not the type the enclosing method's class gave a slot
# of that name (webrick's ChunkedWrapper bumping its response's @sent_size).
class Resp
  attr_reader :sent_size
  def initialize = @sent_size = 0
  def send_plain(n) = (@sent_size += n)
end
class Wrapper
  def initialize(resp) = @resp = resp
  def write(buf)
    return 0 if buf.empty?
    @resp.instance_eval {
      size = buf.bytesize
      @sent_size += size
      size
    }
  end
end
r = Resp.new
r.send_plain(2)
w = Wrapper.new(r)
p w.write("abc"), w.write(""), r.sent_size
