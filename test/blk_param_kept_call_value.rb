# A method that keeps its &block and answers block.call is one function
# taking a proc: a call of it reads what that function returns, boxed where
# the blocks of its call sites answer different types (it was typed as each
# site's block, and the C did not build)
def group(&block)
  @last = block
  block.call
end
def a = group { [1] + [2] }
def b(h) = group { h.each_key { |k| k } }
p a, b({ x: 1 })
def one(&b)
  @k = b
  b.call
end
p one { "str" }.upcase
