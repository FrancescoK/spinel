# A bound Method object is a Method: `when Method` and `is_a?(Method)` match it,
# on a scrutinee typed Method and on one boxed beside other kinds (#9885).
def which(x)
  case x
  when Proc then :proc
  when Method then :method
  else :other
  end
end

def only(x)
  case x
  when Method then 1
  else 2
  end
end

m = 1.method(:+)
p only(m)
p [which(m), which(-> { 1 }), which(3)]
p [m.is_a?(Method), m.kind_of?(Method), m.instance_of?(Method), m.is_a?(Proc)]
vals = [m, -> { 1 }, 3]
p vals.map { |v| v.is_a?(Method) }
p vals.map { |v| case v when Method then :m when Proc then :p else :o end }
