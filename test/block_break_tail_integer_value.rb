# A block that ends in `break`, run where its call's value is an Integer
# that may be nil, leaves the call with the break's value.

def m(&b) = [b.call, :after]
p m { 4 }
p m { break 3 }
p m { break }

def n(&b)
  r = b.call
  [r, :after]
end
p n { 5 }, n { break 6 }

def y(x) = [yield(x), :y]
p y(1) { |v| v + 1 }
p y(2) { |v| break v * 10 }
p y(3) { |v| break if v > 2; v }

def z = [(yield if block_given?), :z]
p z { 7 }, z { break 8 }, z

$c = true
p m { break 9 if $c; 1 }
$c = false
p m { break 9 if $c; 1 }
