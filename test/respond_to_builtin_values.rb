# respond_to? on builtin values held in boxed slots, and on IO handles by
# their kind: Array#to_ary and Hash#to_hash, the IO surface of a File, a
# socket, a server socket, $stdout and a File::Stat, a method a reopening of
# IO adds, and a folded answer that a boxed slot takes.
require "socket"

class IO
  def dormouse_hello = :hi
end

arr = [[1, 2], 1][0]
p arr.respond_to?(:to_ary), arr.respond_to?(:each), arr.respond_to?(:to_str)
hsh = [{ a: 1 }, 1][0]
p hsh.respond_to?(:to_hash), hsh.respond_to?(:each_pair), hsh.respond_to?(:to_ary)
str = ["s", 1][0]
p str.respond_to?(:to_str), str.respond_to?(:to_ary)

env = { "rack.errors" => $stderr, "n" => 1 }
io = env["rack.errors"]
p io.respond_to?(:puts), io.respond_to?(:write), io.respond_to?(:flush), io.respond_to?(:to_ary)

p $stderr.respond_to?(:puts), $stdout.respond_to?(:write), $stdout.respond_to?(:nope)
p $stdout.respond_to?(:path), $stdout.respond_to?(:size), $stdout.respond_to?(:fcntl)
r = $stderr.respond_to?(:puts)
p r

f = File.open(__FILE__)
p f.respond_to?(:path), f.respond_to?(:to_path), f.respond_to?(:size), f.respond_to?(:stat), f.respond_to?(:flock), f.respond_to?(:truncate), f.respond_to?(:fcntl), f.respond_to?(:sysread), f.respond_to?(:lineno), f.respond_to?(:puts), f.respond_to?(:readpartial), f.respond_to?(:accept), f.respond_to?(:peeraddr), f.respond_to?(:dormouse_hello), f.respond_to?(:nope)
bf = [f, 1][0]
p bf.respond_to?(:path), bf.respond_to?(:to_path), bf.respond_to?(:size), bf.respond_to?(:stat), bf.respond_to?(:flock), bf.respond_to?(:truncate), bf.respond_to?(:fcntl), bf.respond_to?(:sysread), bf.respond_to?(:lineno), bf.respond_to?(:puts), bf.respond_to?(:readpartial), bf.respond_to?(:accept), bf.respond_to?(:peeraddr), bf.respond_to?(:nope)
f.close

st = File.stat(__FILE__)
p st.respond_to?(:size), st.respond_to?(:mtime), st.respond_to?(:mode), st.respond_to?(:file?), st.respond_to?(:puts), st.respond_to?(:read), st.respond_to?(:to_path)

srv = TCPServer.new("127.0.0.1", 0)
port = srv.addr[1]
p srv.respond_to?(:accept), srv.respond_to?(:accept_nonblock), srv.respond_to?(:listen), srv.respond_to?(:peeraddr), srv.respond_to?(:puts), srv.respond_to?(:path), srv.respond_to?(:size)
sock = TCPSocket.new("127.0.0.1", port)
p sock.respond_to?(:accept), sock.respond_to?(:peeraddr), sock.respond_to?(:getpeername), sock.respond_to?(:recv), sock.respond_to?(:send), sock.respond_to?(:path), sock.respond_to?(:to_path), sock.respond_to?(:size), sock.respond_to?(:readpartial), sock.respond_to?(:dormouse_hello)
bs = [sock, 1][0]
p bs.respond_to?(:accept), bs.respond_to?(:peeraddr), bs.respond_to?(:recv), bs.respond_to?(:puts), bs.respond_to?(:size)
sock.close
srv.close
