# A local the program only ever writes nil to is boxed, and written to an
# Integer or Float local it leaves that local nil. The nilable marking asked
# only whether the value was a number that may be nil, so the local stayed
# unmarked and its reads took the nil for a number: `Integer === x` answered
# true and `x > 0` false.

def int(x, z)
  nl = nil
  x = nl if z.nil?
  p x
  p(Integer === x)
  p(x > 0)
rescue NoMethodError
  puts "NoMethodError"
end
int(1, nil)
int(2, 3)

def float(x, z)
  nl = nil
  nl = nil if z == 9
  x = nl if z.nil?
  p(x.nil?, Float === x, [x], "<#{x}>")
  p(x < 9)
rescue NoMethodError
  puts "NoMethodError"
end
float(1.5, nil)
float(2.5, 3)

# a local written something else besides nil is no such local
def mixed(x, z)
  v = nil
  v = 4 if z
  x = v if z
  p(x > 0)
end
mixed(1, 2)
