# A method that keeps yield's value where one caller's block answers an
# Array and another's ends in a while or until loop: the loop's value is
# nil, and it goes into the boxed local as nil (#9488).
def with_value
  result = yield 1
  result
end

p with_value { |x| [x, x + 1] }
n = 0
p(with_value { |x| until n > 2; n += x; end })
p n
p(with_value { |x| while n < 6; n += x; end })
p n

def tail_yield = yield(2)
p tail_yield { |x| x * 10 }
p(tail_yield { |x| until n > 9; n += x; end })
p n
