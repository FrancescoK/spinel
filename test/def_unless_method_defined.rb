# `def m ... end unless method_defined?(:m)` in a class body defines m only
# when nothing defined it before that point: an earlier def in this or
# another body of the class, or in a superclass, wins; otherwise the guarded
# def is the method. The pure-Ruby Date defines Time#to_time and friends
# this way.
class Foo
  def a = :first
  def a = :second unless method_defined?(:a)
  def b = :only unless method_defined?(:b)
  unless method_defined?(:c)
    def c = :block_form
  end
  def e = :guarded unless public_method_defined?(:e)
end

class Foo
  def b = :reopened unless method_defined?(:b)
end

class Bar < Foo
  def b = :bar unless method_defined?(:b)
  def d = :d unless method_defined?(:d)
end

class Time
  def to_widget = :widget unless method_defined?(:to_widget)
end

f = Foo.new
p f.a, f.b, f.c, f.e, Bar.new.b, Bar.new.d, Time.at(0).to_widget
