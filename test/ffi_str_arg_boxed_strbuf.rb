# A String reaching an ffi_func :str argument through a boxed parameter is read
# as its bytes, a mutable (shared) String included, not as the box (#5679).
module LibC
  ffi_lib "c"
  ffi_func :strlen, [:str], :int
end
class Sock
  def self.len(s) = LibC.strlen(s)
end
head = String.new
head << "HTTP/1.1 101 Switching Protocols"
p Sock.len(head)
p Sock.len("abc")
x = [head, 1][0]
p Sock.len(x)
