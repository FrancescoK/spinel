# `x[]` with no argument on a boxed value: a Proc or a Method is called, as
# Proc#[] and Method#[] are #call; a String, an Array, a Hash or an Integer
# raises its ArgumentError; an object with no `[]` raises NoMethodError.

class Plain
end

def seven = 7

vals = [-> { 5 }, proc { :p }, method(:seven), ->(a = 1) { a * 10 }, "str", [1, 2], { a: 1 }, 7, Plain.new]
vals.each do |v|
  begin
    p v[]
  rescue ArgumentError, NoMethodError => e
    p [e.class, e.message.sub(/ #<Plain[^>]*>/, " a Plain")]
  end
end

# with arguments, the same values still index or call
p vals[3][4], vals[4][1], vals[5][0], vals[6][:a], vals[7][0]

# a curried Proc
add = ->(a, b) { a + b }.curry
cs = [add[1], 0]
p cs[0][2]
