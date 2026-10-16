# An empty Array in parentheses, or a bare Array.new, handed to a parameter
# that other call sites give a String Array (held as its Strings' handles under
# --share-strings) is built in the parameter's kind. It was built as an
# IntArray, and the C stopped on the pointer types. The callee appends to the
# Strings of both arrays and pushes into a copy of the empty one.
module ShareParenEmpty
  def self.chk(a, b)
    a[0] << "!" if a.size > 0
    b[0] << "?" if b.size > 0
    c = b.dup
    c << a[0]
    p c
    a.size + b.size
  end
  def self.kw(a, b: [])
    c = b.dup
    c << a[0]
    p c
    a.size + b.size
  end
end
p ShareParenEmpty.chk([+"l"], [+"m"])
p ShareParenEmpty.chk([+"l"], ([]))
p ShareParenEmpty.chk([+"l"], ([].freeze))
p ShareParenEmpty.chk([+"l"], Array.new)
p ShareParenEmpty.chk([+"l"], (Array.new))
p ShareParenEmpty.kw([+"k"], b: [+"j"])
p ShareParenEmpty.kw([+"k"], b: ([]))
p ShareParenEmpty.kw([+"k"], b: Array.new)
p ShareParenEmpty.kw([+"k"])
