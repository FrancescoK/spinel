# spinel: not-cruby -- ffi_func is Spinel's own; the answers are libc's.
# A String held as an sp_String * handle (a second name changed in place, an
# ivar changed by setbyte, an appended accumulator) handed to a C function's
# :str argument. The C function reads it for the call and runs no Ruby code,
# so it takes the live buffer instead of a full copy per call; a call with
# another operand that runs code first keeps the copy.
module LibC
  ffi_func :strlen, [:str], :int
  ffi_func :atoi, [:str], :int
  ffi_func :strncmp, [:str, :str, :int], :int
end

s = +"12"
t = s
t << "345"
p LibC.strlen(s), LibC.atoi(s), s

class Box
  def initialize
    @buf = +"abcdef"
    @buf.setbyte(0, 65)
  end

  def peek
    b = @buf
    b.getbyte(1)
  end

  def len = LibC.strlen(@buf)
end
p Box.new.len

acc = +""
alias_acc = acc
10.times { |i| acc << i.to_s; p LibC.strlen(alias_acc) if i == 9 }
p LibC.strncmp(s, t, 3)
p LibC.strncmp(s, t, s.size + 0)
