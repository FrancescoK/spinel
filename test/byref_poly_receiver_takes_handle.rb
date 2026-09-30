# A POLY receiver reaches a method through the cls_id switch, and that switch
# hoists its arguments once -- by the argument's own type, for every arm to
# share. It has no callee to ask, so it passed the value where a byref arm
# wanted the slot, and the C build stopped with
#   expected 'const char **' but argument is of type 'const char *'
#
# So a name a poly receiver can reach kept the value ABI, and every arm
# appended to a copy: this printed "p". Such a name now takes the shared
# handle where the group settles on the slot, a handle arm takes the
# caller's handle, and the answer is CRuby's.
def frag_into(io, n)
  io << "f#{n};"
  nil
end

class A
  def go(b)
    frag_into(b, 1)
  end
end

class B
  def go(b)
    frag_into(b, 2)
  end
end

list = [A.new, B.new]
buf = String.new("p")
list.each { |o| o.go(buf) }
p buf

# a statically resolved call into the same method appends to the caller's too
def wrap_into(io)
  frag_into(io, 9)
  nil
end
direct = String.new("d")
wrap_into(direct)
p direct
