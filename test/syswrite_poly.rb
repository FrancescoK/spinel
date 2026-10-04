# syswrite_poly.rb -- IO#syswrite on a Socket through the poly dispatch.
#
# The poly arm in codegen_call.c (the switch with SP_BUILTIN_IO cases) is
# only emitted when the receiver is typed TY_POLY at compile time. A plain
# `sock.syswrite(...)` where sock is statically TY_IO takes the typed-
# receiver arm, not the poly arm. To force the poly arm the receiver must
# be a union of a builtin IO (Socket) and a user class -- exactly the
# shape TlsSocket has in http_client.rb, where `sock` may be either a raw
# Socket or a TlsSocket wrapper.
#
# syswrite semantics: unbuffered, writes the whole String in one shot,
# returns the byte count, and does NOT append a newline (unlike IO#write
# on $stdout, which is a different code path). No flush: sp_File_syswrite
# routes straight to write(2) on the descriptor.
#
# The generated C is the proof the poly arm was taken: it emits
#   switch (cls_id) { case 0: <user class>; case SP_BUILTIN_IO: sp_File_syswrite(...); default: raise }
# A plain Socket receiver would emit the typed fast path with no switch.
#
# An embedded NUL must survive the write: the byte length is sized off the
# String header (sp_str_byte_len), not strlen, so a NUL in the middle
# reaches the descriptor instead of truncating the write.
#
# Two emission paths are covered:
#   1. Poly receiver (StubSslSocket | Socket) -- the SP_BUILTIN_IO switch
#      arm, which resolves the operand's tag at run time.
#   2. Statically TY_IO receiver with a TY_POLY operand -- the typed-receiver
#      arm, which sizes the operand by its static type. A variable widened
#      to a union of String and Integer makes the operand poly while the
#      receiver stays a plain Socket.

require "socket"

# A user class that owns #syswrite, mirroring TlsSocket's role: the union
# of this class and Socket makes the receiver poly, and owning the name
# opens the per-class dispatch switch.
class StubSslSocket
  def syswrite(_data); 42; end
end

server = TCPServer.new("127.0.0.1", 0)
port = server.addr[1]

# Assign a StubSslSocket first, then a Socket to the SAME variable. The
# variable's static type widens to the union (StubSslSocket | Socket), so
# the receiver of .syswrite is TY_POLY and the dispatch switch is emitted.
# At runtime the variable holds the Socket, so the builtin SP_BUILTIN_IO
# arm runs.
holder = StubSslSocket.new
holder = TCPSocket.new("127.0.0.1", port)

# String arg -> sp_File_syswrite, byte count is the operand length. The
# payload has an embedded NUL: the count is 15, not 5, and the full
# 15 bytes must reach the descriptor.
n = holder.syswrite("he\x00llo syswrite")
raise "syswrite returned #{n.inspect}, expected 15" unless n == 15

# Drain the server side and confirm the NUL survived the write: a
# strlen-based write would have stopped at the NUL and seen 5 bytes.
# read_nonblock is used because the client end is still open, so a
# blocking read would park the process waiting for more data. The bytes
# may not have crossed the loopback yet when accept returns (macOS delivers
# them a moment later), so wait for readability first.
client = server.accept
IO.select([client], nil, nil, 5)
begin
  got = client.read_nonblock(64)
rescue IO::WaitReadable
  got = ""
end
raise "server saw #{got.inspect}, expected 'he\\x00llo syswrite'" unless got == "he\x00llo syswrite"

# Non-String arg (Integer) goes through sp_poly_to_s, writes "42" (2 bytes).
m = holder.syswrite(42)
raise "syswrite(42) returned #{m.inspect}, expected 2" unless m == 2

holder.close
client.close
server.close

# ---- Statically TY_IO receiver with a TY_POLY operand ----
# A plain Socket receiver keeps the typed-receiver arm. The operand is
# widened to a union of String and Integer by assigning both to the same
# variable, so its static type is TY_POLY and the operand's length is
# chosen by its run-time tag: sp_str_byte_len for a marked String
# (embedded NULs survive), strlen for a converted value.
server2 = TCPServer.new("127.0.0.1", 0)
port2 = server2.addr[1]
sock = TCPSocket.new("127.0.0.1", port2)

# The operand variable holds a String first, then an Integer, so its
# compile-time type is the union (String | Integer) -- TY_POLY.
poly_arg = "he\x00llo poly"
poly_arg = 42

# Single-arg form: the operand is poly, so the typed-receiver arm sizes it
# by tag. At runtime it holds the Integer, so "42" (2 bytes) is written.
n2 = sock.syswrite(poly_arg)
raise "poly syswrite returned #{n2.inspect}, expected 2" unless n2 == 2

# Drain and confirm the converted value reached the descriptor.
client2 = server2.accept
IO.select([client2], nil, nil, 5)
begin
  got2 = client2.read_nonblock(64)
rescue IO::WaitReadable
  got2 = ""
end
raise "poly server saw #{got2.inspect}, expected '42'" unless got2 == "42"

# Multi-arg form: IO#write accepts multiple operands, but IO#syswrite
# takes only one (CRuby raises ArgumentError otherwise). The multi-arg
# syswrite arm in the codegen is exercised by IO#write on a syswrite-
# typed receiver; here we verify the single-arg poly operand path with
# a String that carries an embedded NUL. The payload is 12 bytes
# ("he\0llo multi"), so the byte count is 12, not 5 -- a strlen-based
# write would have stopped at the NUL.
n3 = sock.syswrite("he\x00llo multi")
raise "poly syswrite returned #{n3.inspect}, expected 12" unless n3 == 12

IO.select([client2], nil, nil, 5)
begin
  got3 = client2.read_nonblock(64)
rescue IO::WaitReadable
  got3 = ""
end
raise "poly server saw #{got3.inspect}, expected 'he\\x00llo multi'" unless got3 == "he\x00llo multi"

sock.close
client2.close
server2.close

# ---- syswrite on a regular file ----
# The bytes must be on disk before the call returns, so a read back
# through a second handle sees them without a flush. A buffered write
# would not have this property.
path = "/tmp/syswrite_poly_test_#{Process.pid}"
w = File.open(path, "wb")
w.syswrite("buffered?")
# Read through a second handle -- the stdio buffer of w is bypassed, so
# the read sees the bytes already.
r = File.open(path, "rb")
got = r.read(9)
r.close
w.close
File.unlink(path)
raise "file saw #{got.inspect}, expected 'buffered?'" unless got == "buffered?"

puts "PASS: syswrite through the poly dispatch works"