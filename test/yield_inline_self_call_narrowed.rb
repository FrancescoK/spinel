# A method that yields is spliced into each caller, a subclass's too. A bare
# call in it that a subclass overrides answers a box in the method's own
# class (every override's answer joined), and in the subclass's copy the
# override's narrower answer is boxed for that slot.
class Base
  def message(_r = nil) = [:base, "b"][ARGV.size]
  def size_of = [1.5, nil][ARGV.size]

  def report(r, message: nil)
    msg = message || message(r)
    n = size_of
    yield 1 if block_given?
    p [msg, n]
  end

  def plain(r)
    msg = message(r)
    yield r if block_given?
    msg
  end
end

class A < Base
  def message(_r = nil) = "a"
  def size_of = 7

  def run
    report(1) { |x| p x }
    report(2, message: "x")
    p plain(3) { |x| p x + 1 }
  end
end

class A2 < A
  def message(_r = nil) = 42
end

class B < Base
  def run
    report(3)
    p plain(4)
  end
end

A.new.run
A2.new.run
B.new.run

# an override that answers an Integer or a Float that may be nil: boxed
# with its nil
class NBase
  def count(_r = nil) = [:base, "b"][ARGV.size]
  def weight = "w"

  def report(r)
    n = count(r)
    w = weight
    yield 1 if block_given?
    p [n, w]
  end
end

class NA < NBase
  def count(r = nil) = r > 1 ? r : nil
  def weight = ARGV.size > 3 ? nil : 2.5

  def run
    report(1) { |x| x }
    report(2) { |x| x }
  end
end

NA.new.run
NBase.new.report(3)
