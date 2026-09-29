# A global write answers the stored value: as a method's last expression,
# with a yield on the right, and as an argument.

def twice(x); $twice = x * 2; end
p twice(3)

def label(x); $label = "s#{x}"; end
p label(4)

def boxed(x); $boxed = [x]; end
p boxed(5)

def through(x); $through = yield(x); end
p through(3) { |v| v * 2 }
p $through

def endless(x) = $endless = yield(x)
p endless(2) { |v| v + 40 }

def only_if(x); $only_if = x if x > 0; end
p only_if(2)
p only_if(-1)

class Box
  def put(x); $put = yield(x); end
end
p Box.new.put(7) { |v| "v#{v}" }

p($arg = 3)
def paren(x); a = ($paren = yield(x)); a; end
p paren(1) { |v| v + 10 }
