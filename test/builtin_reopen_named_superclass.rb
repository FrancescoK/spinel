# Reopening a builtin while naming its own superclass -- `class Rational <
# Numeric`, as the bigdecimal gem's util.rb does -- is the same reopening as
# `class Rational`: Ruby accepts the superclass because it is the one the
# class already has. It reopens the runtime's class, not a new one.
class Rational < Numeric
  def half = self / 2
end

class Complex < Numeric
  def twice = self * 2
end

class Integer < Numeric
  def kilo = self * 1000
end

class String < Object
  def shout = upcase + "!"
end

p Rational(3, 4).half, Complex(1, 2).twice, 3.kilo, "hi".shout
