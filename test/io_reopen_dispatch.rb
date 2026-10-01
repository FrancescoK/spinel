# Methods a program adds by reopening IO, File or a socket class: called and
# asked respond_to? on a typed handle and on one in a boxed slot. Which ones
# a handle has follows its kind, as in CRuby.
require "socket"

class IO
  def tag = "io:#{self.class}"
  def label(prefix, n) = "#{prefix}-#{n}"
  private def secret = 1
end

class File
  def tag = "file:#{File.basename(path)}"
  def first_line = File.read(path).lines.first.strip
end

class BasicSocket
  def tag = "socket"
end

class TCPServer
  def port_number = addr[1].is_a?(Integer)
end

f = File.open(__FILE__)
p f.tag, f.label("a", 1), f.first_line
p $stdout.tag, $stdout.respond_to?(:first_line), $stdout.respond_to?(:label)
p f.respond_to?(:first_line), f.respond_to?(:secret), f.respond_to?(:port_number)

slots = [f, $stdout, 1]
slots.each do |v|
  p [v.respond_to?(:tag), v.respond_to?(:first_line), v.respond_to?(:secret)]
end
bf = slots[0]
p bf.tag, bf.label("b", 2), bf.first_line
bo = slots[1]
p bo.tag
p %i[tag first_line label nope].map { |m| bf.respond_to?(m) }

srv = TCPServer.new("127.0.0.1", 0)
sock = TCPSocket.new("127.0.0.1", srv.addr[1])
p srv.tag, sock.tag, srv.port_number, sock.label("c", 3)
p sock.respond_to?(:port_number), srv.respond_to?(:port_number), sock.respond_to?(:first_line)
held = { "server" => srv, "client" => sock, "n" => 1 }
bs = held["server"]
bc = held["client"]
p bs.tag, bc.tag, bs.port_number
p bs.respond_to?(:port_number), bc.respond_to?(:port_number), bc.respond_to?(:tag), bc.respond_to?(:first_line)
sock.close
srv.close
f.close

# a private one answers only with include_all, and an explicit call raises
p f.respond_to?(:secret, true), slots[0].respond_to?(:secret, true)
begin; f.secret; rescue NoMethodError; p :private; end
begin; slots[0].secret; rescue NoMethodError; p :private_boxed; end
p slots[0].__send__(:secret)

# a File method on a stream that is not a File
begin; $stdout.first_line; rescue NoMethodError; p :not_a_file; end

# reopenings answering different types
class IO
  def kind_val = 1
  def shout = "io!"
  alias yell shout
end
class File
  def kind_val = "file"
end
g = File.open(__FILE__)
p g.kind_val, $stdout.kind_val, $stdout.yell
g.close

# the nearest reopening decides, visibility included: a private IPSocket#near
# hides IO#near from a socket's respond_to?
class IO
  def near = 1
end
class IPSocket
  private def near = 2
end
srv2 = TCPServer.new("127.0.0.1", 0)
s2 = TCPSocket.new("127.0.0.1", srv2.addr[1])
m3 = :near
p s2.respond_to?(:near), [s2, 1][0].respond_to?(m3), [s2, 1][0].respond_to?(m3, true), $stdout.respond_to?(:near)
s2.close
srv2.close

# a File override of a builtin: a kind no reopening serves gets the builtin
class File
  def sync = "file-sync"
end
rp, wp = IO.pipe
wp.write("piped")
wp.close
p rp.read, $stdout.sync, File.open(__FILE__).sync

# an argument's own reopened call keeps its dispatch, and the arguments run
# once whichever arm the kind picks
class File
  def getbyte = 66
  def putc(c) = "file-putc"
  def print(s) = "file-print"
  def write(s) = "file-write"
  def gets = "file-gets"
end
fg = File.open(__FILE__)
calls = 0
arg = -> { calls += 1; "x" }
rp2, wp2 = IO.pipe
wp2.putc(fg.getbyte)
wp2 << fg.getbyte
wp2.print(fg.getbyte.to_s + arg.call)
wp2.write(arg.call)
wp2.write("\n")
wp2.close
p rp2.gets, calls, fg.print("z"), fg.gets

# the receiver runs before the arguments
$order = []
def io_of(x) = ($order << :recv; x)
def arg_of(s) = ($order << :arg; s)
rp3, wp3 = IO.pipe
io_of(wp3).write(arg_of("o"))
wp3.close
p rp3.read, $order
