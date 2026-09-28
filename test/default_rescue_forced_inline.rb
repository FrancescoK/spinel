# A parameter default that rescues is filled in at the call site, so the
# calling method must not be forced inline: gcc refuses always_inline on a
# function that calls setjmp.

def f(a, b = begin; Integer("zz"); rescue ArgumentError; 8; end) = [a, b]
def g(i) = f(i)
p g(1)

def h(a, b = (Integer(a) rescue -1)) = [a, b]
def hh(s) = h(s)
p hh("12")
p hh("zz")

class K
  def initialize(a:, b: begin; Integer("zz"); rescue ArgumentError; 8; end) = (@v = [a, b])
  attr_reader :v
end
def mk(i) = K.new(a: i).v
p mk(1)
def mk2(h) = [K].first.new(**h).v
p mk2({a: 2})

def inner(x = (raise "no" rescue 5)) = x
def outer(y = inner) = y
def top = outer
p top
