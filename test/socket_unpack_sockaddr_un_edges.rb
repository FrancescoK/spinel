# Socket.unpack_sockaddr_un drops only the trailing NULs, so an abstract
# socket name keeps its leading NUL, and a String longer than a
# struct sockaddr_un is rejected rather than cut down to the path.
require "socket"

fam = Socket.sockaddr_un("/var/x").byteslice(0, 2)

p Socket.unpack_sockaddr_un(fam + "\0abstract").bytes
p Socket.unpack_sockaddr_un(fam + "a\0b\0\0").bytes
p Socket.unpack_sockaddr_un(fam + "/var/x\0\0\0")
p Socket.unpack_sockaddr_un(fam)
p Socket.unpack_sockaddr_un(fam + "x" * 100).bytesize

# The size of a struct sockaddr_un differs by platform, so only the start of
# the message is checked.
begin
  Socket.unpack_sockaddr_un(fam + "/var/x" + "\0" * 200)
rescue TypeError => e
  p e.message.start_with?("too long sockaddr_un - 208 longer than ")
end
