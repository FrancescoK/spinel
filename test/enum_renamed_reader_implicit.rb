# A reader named detect or collect_concat, called without a receiver from the
# class's own methods, from a block in them, and through self., answers its
# ivar; the pre-pass's find and flat_map are the builtin copies' names, not
# the program's.
class X
  attr_reader :detect, :collect_concat
  def initialize; @detect = 1; @collect_concat = 2; end
  def a = detect + collect_concat
  def b = [1].map { |_| detect }
  def c = self.detect
end
x = X.new
p x.a, x.b, x.c
