# A yielding method whose last statement is a parenthesized sequence
# (`(1; x)`), called with a block, answers the String x itself. The tail was
# taken for the parentheses and the program refused as one that would hand
# on a copy; the tail is the sequence's last statement.
def m(x)
  yield
  (1; x)
end
s = +"a"
r = m(s) { 2 }
r << "!"
p s, r
