# `[]` on a boxed value that may be a Struct class: the arity guard of the
# builtin `[]` reads the receiver's temp, so it runs inside the expression
# that holds that temp, not ahead of the statement, where it read whatever
# an earlier statement had left in the slot (a String raised ArgumentError).
S = Struct.new(:a, :b)
s = [S, 0][0]
str = ["abc", 0][0]
p str[1]
p s[]
p s[1, 2]
begin
  p str[]
rescue ArgumentError => e
  p e.message
end
