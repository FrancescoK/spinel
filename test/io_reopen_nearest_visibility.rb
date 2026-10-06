# A reopened IO method's visibility is the nearest reopening's, for
# respond_to? as for the call, and a refusal names the handle's own class.
require "socket"
class IO
  def foo = "io"
  private def tag = "io"
  protected def prot = 1
end
class IPSocket
  private def foo = "ip"
end
s = TCPServer.new("127.0.0.1", 0)
c = TCPSocket.new("127.0.0.1", s.addr[1])
p c.respond_to?(:foo), c.respond_to?(:foo, true)
p [c, 1][0].respond_to?(:foo)
m = :foo
p c.respond_to?(m), c.respond_to?(m, true)
p((c.foo rescue $!.class))
p $stdout.respond_to?(:foo), $stdout.foo
f = File.open(__FILE__)
[f, $stdout, c, [f, 1][0]].each do |x|
  begin
    x.tag
  rescue NoMethodError => e
    puts e.message
  end
  begin
    x.prot
  rescue NoMethodError => e
    puts e.message
  end
end
p f.respond_to?(:tag), f.respond_to?(:tag, true)
m = :tag
p f.respond_to?(m), f.respond_to?(m, true)
c.close
s.close
