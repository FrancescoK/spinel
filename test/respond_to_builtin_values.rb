# respond_to? on builtin values held in boxed slots, and on $stderr /
# $stdout: Array#to_ary and Hash#to_hash, the IO surface, and a folded
# answer that a boxed slot takes.
require "socket"

arr = [[1, 2], 1][0]
p arr.respond_to?(:to_ary), arr.respond_to?(:each), arr.respond_to?(:to_str)
hsh = [{ a: 1 }, 1][0]
p hsh.respond_to?(:to_hash), hsh.respond_to?(:each_pair), hsh.respond_to?(:to_ary)
str = ["s", 1][0]
p str.respond_to?(:to_str), str.respond_to?(:to_ary)

env = { "rack.errors" => $stderr, "n" => 1 }
io = env["rack.errors"]
p io.respond_to?(:puts), io.respond_to?(:write), io.respond_to?(:flush), io.respond_to?(:to_ary)

p $stderr.respond_to?(:puts)
p $stdout.respond_to?(:write)
p $stdout.respond_to?(:nope)
r = $stderr.respond_to?(:puts)
p r

srv = TCPServer.new("127.0.0.1", 19393)
sock = [TCPSocket.new("127.0.0.1", 19393), 1][0]
p sock.respond_to?(:readpartial), sock.respond_to?(:peeraddr), sock.respond_to?(:to_ary)
typed = TCPSocket.new("127.0.0.1", 19393)
p typed.respond_to?(:peeraddr), typed.respond_to?(:puts), typed.respond_to?(:nope)
f = File.open(__FILE__)
p f.respond_to?(:peeraddr), f.respond_to?(:read)
f.close
