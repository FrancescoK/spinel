# String#replace with a boxed argument (the answer of a call dispatched on a
# class held in a variable): the value was handed to a const char * as is,
# and the C did not compile (ffi-rzmq's Socket#recv_string).
class M1
  def copy_out = "a"
end
class M2
  def copy_out = "bb"
end
class M3
  def copy_out = 3
end
class Sock
  def initialize(k) = @klass = k
  def recv_string(string)
    message = @klass.new
    string.replace(message.copy_out)
    string
  end
end
p Sock.new([M1, M2, M3][ARGV.size]).recv_string(String.new)
p Sock.new(M2).recv_string(String.new("x"))
