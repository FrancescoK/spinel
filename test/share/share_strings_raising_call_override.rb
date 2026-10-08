# A program's methods named raise and fail still return values.
S = +"s"
def source = S
def raise = +"raised value"
def fail = +"failed value"
def pick_raise(x)
  source
  x ? S : raise
end
def pick_fail(x)
  source
  case x; in Integer then S; else fail; end
end
p pick_raise(false)
p pick_raise(false).equal?(S)
p pick_fail(false)
p pick_fail(false).equal?(S)
p S
