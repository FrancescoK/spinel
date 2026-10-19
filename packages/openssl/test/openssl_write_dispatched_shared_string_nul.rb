# A String the program changed in place is a shared handle, and a `write`
# dispatched on a receiver that may be an IO or an SSLSocket took the
# handle's box through the IO arm's other branch, which sizes the bytes by
# strlen: a frame with a NUL byte stopped there (#9602). The arm reads the
# handle's bytes with their length.
require "openssl"

def frame(type, body)
  out = "".b
  out << [type, body.bytesize].pack("nn")
  out << body
  out
end

class Link
  def initialize(conn)
    @conn = conn
  end

  def deliver(bytes)
    @conn.write(bytes)
  end
end

r, w = IO.pipe
link = Link.new(w)
link.deliver(frame(0x0113, "Jayang".b))
link.deliver("Guui")
ctx = OpenSSL::SSL::SSLContext.new
Link.new(OpenSSL::SSL::SSLSocket.new(r, ctx)) if r.nil?
w.close
p r.read.bytes
