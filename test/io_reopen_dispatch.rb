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
