# A method added by reopening Object is every object's: a receiverless call
# in another class's instance method, in a block there, or at the top level
# reaches it, a yielding one with its block too, and its arguments type its
# parameters (#5779).
class Object
  def plain_helper
    42
  end

  def tagged(x) = "#{self.class}:#{x}"

  def yielder
    yield
  end

  def twice(n)
    yield(n) + yield(n + 1)
  end
end

class Report
  def a = plain_helper
  def b = self.plain_helper
  def c = yielder { 3 }
  def d = self.yielder { 4 }
  def e = tagged(5)
  def f = [1, 2].map { |i| plain_helper + i }
  def g = twice(10) { |v| v * 2 }
end

class Own
  def plain_helper = :own
  def a = plain_helper
end

class Sub < Report
  def h = tagged(:sub)
end

r = Report.new
p [r.a, r.b, r.c, r.d, r.e, r.f, r.g]
p Own.new.a
p Sub.new.h
p plain_helper
p(yielder { :top })
