# A toplevel method whose last expression writes an ivar answers the
# stored value, as the same method in a class does.

def count(x); @count = x + 1; end
p count(4)

def through(x); @through = yield(x); end
p through(3) { |v| v * 2 }
p @through

def label(x); @label = "s#{x}"; end
p label(5)

def list(x); @list = [x, x]; end
p list(6)

def mixed(x); @mixed = x; end
p mixed(1)
p mixed("one")

def float_of(x); @float_of = x * 1.5; end
p float_of(2)
