# IO#getc and #readchar answer one byte on a binary handle (a socket, a File
# opened "rb", a handle put in binmode) and one character on a text handle.
# They always read on after a byte that looked like a UTF-8 lead: a binary
# frame ending in such a byte took the next byte with it, and on a socket
# waited for bytes the peer had not sent (#7312).
require "socket"
require "tmpdir"

server = TCPServer.new("127.0.0.1", 0)
client = TCPSocket.new("127.0.0.1", server.addr[1])
peer = server.accept
peer.write("\xCEX\xE3\x81\x82".b)
peer.close
p client.binmode?
c = client.readchar
p c.bytes, c.encoding
p client.getc.bytes
p client.getc.bytes
p client.read.bytes
p client.getc
client.close
server.close

path = File.join(Dir.tmpdir, "spinel_getc_bin_#{Process.pid}.dat")
File.binwrite(path, "\xCE\x9Bz")
File.open(path, "rb") do |f|
  p f.binmode?
  g = f.getc
  p g.bytes, g.encoding
  p f.readchar.bytes
  p f.getc.bytes
  p f.getc
  begin
    f.readchar
  rescue EOFError => e
    puts "EOFError"
  end
end
File.open(path, "r") do |f|
  p f.binmode?
  g = f.getc
  p g.bytes, g.encoding
  p f.getc.bytes
  f.rewind
  f.binmode
  p f.getc.bytes
end
File.delete(path)
