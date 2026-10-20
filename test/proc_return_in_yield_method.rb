# A method that yields and also creates a proc that `return`s. The proc leaves
# the method through the method's proc-return frame, which a method spliced into
# its caller does not have: the splice named the frame (`_h`) where none was
# declared and the C did not build. A yielding method that creates such a proc
# is a function of its own, whose block is passed as a proc, and has the frame.
def first_big(a)
  pr = proc { |x| return x if x > 1 }
  a.each { |x| yield x; pr.call(x) }
  nil
end

p first_big([1, 2, 3]) { |x| x }
p first_big([0, 1]) { |x| x * 2 }
seen = []
p first_big([1, 2, 3]) { |x| seen << x }
p seen

def label(a)
  fin = lambda { |x| return "lam#{x}" }
  pr = proc { |x| return "proc#{x}" if x.odd? }
  a.map { |x| yield(x); pr.call(x); fin.call(x) }
end

p label([2, 4]) { |x| x }
p label([2, 3, 4]) { |x| x.to_s }

class Finder
  def initialize(xs) = @xs = xs

  def find_by
    probe = proc { |x| return [:found, x] if yield(x) }
    @xs.each { |x| probe.call(x) }
    :none
  end
end

f = Finder.new([1, 2, 3, 4])
p f.find_by { |x| x > 2 }
p f.find_by { |x| x > 9 }
p f.find_by { |x| x == 1 }

# a caller defined before the method it hands its block to
def m2(a)
  m1(a) { |x| return "m2:#{x}" if x > 1; yield x }
  "m2 none"
end

def m1(a)
  pr = proc { |x| return x if x > 5 }
  a.each { |x| yield x; pr.call(x) }
  nil
end

p m2([1, 2]) { |x| x }, m2([1]) { |x| x }, m1([1, 9]) { |x| x }
