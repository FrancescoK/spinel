# `recipient.public_send(m, *args)` and `h.slice(*keys)` lower to an arity
# test over the splat's own count (`args.length == 1`), a builtin_only call
# that no method of the program is a target of: its emitter takes the
# builtin's arm alone. With the splat poly and an unrelated class whose
# `length` or `size` answers nil, the nullability analysis still scanned the
# program's methods of the name for the count, marked it nil-able, and the
# count's slot became an sp_oint the builtin's plain sp_int could not
# initialize: the generated C did not compile under --int-overflow=promote.
class Buf
  def size = nil
  def length = nil
end
class A
  def go(*args) = args.size
  def name = "a"
end
class B
  def go(*args) = "b#{args.size}"
  def name = 7
end
TABLE = { go: [1, 2], name: [], buf: Buf.new }
def call_it(recipient, m)
  method = m
  args = TABLE[m]
  recipient.public_send(method, *args)
end
p call_it(A.new, :go)
p call_it(B.new, :go)
p call_it(A.new, :name)
p call_it(B.new, :name)

KEYS = { two: [:a, :c], one: [:b], none: [], buf: Buf.new }
def narrow(h, m)
  keys = KEYS[m]
  h.slice(*keys)
end
h = { a: 1, b: 2, c: 3 }
p narrow(h, :two)
p narrow(h, :one)
p narrow(h, :none)
p Buf.new.size
p Buf.new.length
